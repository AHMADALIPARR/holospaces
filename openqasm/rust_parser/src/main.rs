use std::env;
use std::fs;

#[derive(Debug, Clone)]
enum Expr {
    Float(f64),
    Int(i64),
    Ident(String),
}

#[derive(Debug, Clone)]
enum Stmt {
    Version(String),
    Include(String),
    QubitDecl { name: String, size: usize },
    Decl { ty: String, name: String, size: Option<usize> },
    Gate { name: String, params: Vec<Expr>, qubits: Vec<String> },
}

/// Tokenize a single line into a vector of tokens.
fn tokenize(line: &str) -> Vec<String> {
    let mut tokens = Vec::new();
    let mut current = String::new();
    let mut in_string = false;

    for c in line.chars() {
        if c == '"' {
            in_string = !in_string;
            current.push(c);
        } else if in_string {
            current.push(c);
        } else if c.is_whitespace()
            || c == ';'
            || c == '['
            || c == ']'
            || c == ','
            || c == '('
            || c == ')'
        {
            if !current.is_empty() {
                tokens.push(current.clone());
                current.clear();
            }
            if !c.is_whitespace() {
                tokens.push(c.to_string());
            }
        } else {
            current.push(c);
        }
    }
    if !current.is_empty() {
        tokens.push(current);
    }
    tokens
}

/// Parse a single expression starting at index *i.
fn parse_expr(tokens: &[String], i: &mut usize) -> Expr {
    if *i >= tokens.len() {
        panic!("Unexpected end of expression");
    }
    let t = &tokens[*i];
    if t.starts_with('"') {
        let s = t.trim_matches('"').to_string();
        *i += 1;
        Expr::Ident(s)
    } else if t.parse::<f64>().is_ok() {
        if t.contains('.') {
            let v: f64 = t.parse().unwrap();
            *i += 1;
            Expr::Float(v)
        } else {
            let v: i64 = t.parse().unwrap();
            *i += 1;
            Expr::Int(v)
        }
    } else {
        let ident = t.clone();
        *i += 1;
        // Handle array access: ident[expr]
        if *i < tokens.len() && tokens[*i] == "[" {
            *i += 1;
            let _idx = parse_expr(tokens, i);
            if *i < tokens.len() && tokens[*i] == "]" {
                *i += 1;
            }
        }
        Expr::Ident(ident)
    }
}

/// Parse a statement from a token slice.
fn parse_stmt(tokens: &[String]) -> Option<Stmt> {
    if tokens.is_empty() {
        return None;
    }
    match tokens[0].as_str() {
        "OPENQASM" => {
            if tokens.len() >= 2 {
                Some(Stmt::Version(tokens[1].clone()))
            } else {
                None
            }
        }
        "include" => {
            if tokens.len() >= 2 {
                let name = tokens[1].trim_matches('"').to_string();
                Some(Stmt::Include(name))
            } else {
                None
            }
        }
        "qubit" => {
            // qubit[size] name ;
            if tokens.len() >= 5 && tokens[1] == "[" {
                let size: usize = tokens[2].parse().ok()?;
                if tokens[3] != "]" {
                    return None;
                }
                let name = tokens[4].clone();
                Some(Stmt::QubitDecl { name, size })
            } else {
                None
            }
        }
        "float" | "int" => {
            let ty = tokens[0].clone();
            if tokens.len() >= 3 {
                let name = tokens[1].clone();
                let size = if tokens.len() >= 6 && tokens[2] == "[" {
                    tokens[3].parse().ok()
                } else {
                    None
                };
                Some(Stmt::Decl { ty, name, size })
            } else {
                None
            }
        }
        // Gate names
        "h" | "cx" | "rz" | "x" | "y" | "z" | "s" | "t" => {
            let name = tokens[0].clone();
            let mut i = 1usize;
            let mut params = Vec::new();

            // Optional parameter list: ( expr , expr , ... )
            if i < tokens.len() && tokens[i] == "(" {
                i += 1;
                while i < tokens.len() && tokens[i] != ")" {
                    params.push(parse_expr(tokens, &mut i));
                    if i < tokens.len() && tokens[i] == "," {
                        i += 1;
                    }
                }
                if i < tokens.len() && tokens[i] == ")" {
                    i += 1;
                }
            }

            // Qubit list: q , q[0] , ...
            let mut qubits = Vec::new();
            while i < tokens.len() && tokens[i] != ";" {
                if tokens[i] == "," {
                    i += 1;
                    continue;
                }
                if i + 2 < tokens.len() && tokens[i + 1] == "[" {
                    let reg = tokens[i].clone();
                    let idx = tokens[i + 2].clone();
                    qubits.push(format!("{}[{}]", reg, idx));
                    i += 4; // reg, [, idx, ]
                } else {
                    qubits.push(tokens[i].clone());
                    i += 1;
                }
            }
            Some(Stmt::Gate {
                name,
                params,
                qubits,
            })
        }
        _ => None,
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: {} <qasm_file>", args[0]);
        std::process::exit(1);
    }

    let content = match fs::read_to_string(&args[1]) {
        Ok(c) => c,
        Err(e) => {
            eprintln!("Failed to read file: {}", e);
            std::process::exit(1);
        }
    };

    let mut ast: Vec<Stmt> = Vec::new();
    for line in content.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with("//") {
            continue;
        }
        let tokens = tokenize(line);
        if let Some(stmt) = parse_stmt(&tokens) {
            ast.push(stmt);
        }
    }

    for stmt in &ast {
        println!("{:?}", stmt);
    }
}
