//! Production zero-dependency OpenQASM 3 subset parser
//! for the H-Rz-CNOT-Rz-CNOT circuit with float[2] angles.
use std::env;
use std::fs;

#[derive(Debug, Clone)]
enum Expr {
    Float(f64),
    Int(i64),
    Ident(String),
    ArrayAccess(String, Box<Expr>),
}

#[derive(Debug, Clone)]
enum Stmt {
    Version(String),
    Include(String),
    QubitDecl { name: String, size: usize },
    Decl { ty: String, name: String, size: Option<usize> },
    Gate { name: String, params: Vec<Expr>, qubits: Vec<String> },
}

fn tokenize(line: &str) -> Vec<String> {
    let mut tokens = Vec::new();
    let mut cur = String::new();
    let mut in_str = false;
    for c in line.chars() {
        if c == '"' {
            in_str = !in_str;
            cur.push(c);
        } else if in_str {
            cur.push(c);
        } else if c.is_whitespace() || "[](),;".contains(c) {
            if !cur.is_empty() {
                tokens.push(std::mem::take(&mut cur));
            }
            if !c.is_whitespace() {
                tokens.push(c.to_string());
            }
        } else {
            cur.push(c);
        }
    }
    if !cur.is_empty() { tokens.push(cur); }
    tokens
}

fn parse_expr(tokens: &[String], i: &mut usize) -> Expr {
    if *i >= tokens.len() { panic!("EOF in expr"); }
    let t = &tokens[*i];
    *i += 1;
    if t.starts_with('"') {
        Expr::Ident(t.trim_matches('"').to_string())
    } else if let Ok(v) = t.parse::<f64>() {
        if t.contains('.') { Expr::Float(v) } else { Expr::Int(t.parse().unwrap()) }
    } else {
        let ident = t.clone();
        if *i < tokens.len() && tokens[*i] == "[" {
            *i += 1;
            let idx = parse_expr(tokens, i);
            if *i < tokens.len() && tokens[*i] == "]" { *i += 1; }
            Expr::ArrayAccess(ident, Box::new(idx))
        } else {
            Expr::Ident(ident)
        }
    }
}

fn parse_stmt(tokens: &[String]) -> Option<Stmt> {
    if tokens.is_empty() { return None; }
    match tokens[0].as_str() {
        "OPENQASM" if tokens.len() >= 2 => Some(Stmt::Version(tokens[1].clone())),
        "include" if tokens.len() >= 2 => Some(Stmt::Include(tokens[1].trim_matches('"').to_string())),
        "qubit" if tokens.len() >= 5 && tokens[1] == "[" => {
            let size = tokens[2].parse().ok()?;
            Some(Stmt::QubitDecl { name: tokens[4].clone(), size })
        }
        "float" | "int" => {
            let ty = tokens[0].clone();
            let name = tokens.get(1)?.clone();
            let size = if tokens.get(2) == Some(&"[".to_string()) {
                tokens.get(3)?.parse().ok()
            } else { None };
            Some(Stmt::Decl { ty, name, size })
        }
        "h" | "cx" | "rz" | "x" | "y" | "z" | "s" | "t" => {
            let name = tokens[0].clone();
            let mut i = 1;
            let mut params = Vec::new();
            if tokens.get(i) == Some(&"(".to_string()) {
                i += 1;
                while i < tokens.len() && tokens[i] != ")" {
                    params.push(parse_expr(tokens, &mut i));
                    if tokens.get(i) == Some(&",".to_string()) { i += 1; }
                }
                if tokens.get(i) == Some(&")".to_string()) { i += 1; }
            }
            let mut qubits = Vec::new();
            while i < tokens.len() && tokens[i] != ";" {
                if tokens[i] == "," { i += 1; continue; }
                if i + 2 < tokens.len() && tokens[i+1] == "[" {
                    qubits.push(format!("{}[{}]", tokens[i], tokens[i+2]));
                    i += 4;
                } else {
                    qubits.push(tokens[i].clone());
                    i += 1;
                }
            }
            Some(Stmt::Gate { name, params, qubits })
        }
        _ => None,
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: {} <qasm>", args[0]);
        std::process::exit(1);
    }
    let content = fs::read_to_string(&args[1]).expect("read file");
    let mut ast = Vec::new();
    for line in content.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with("//") { continue; }
        let tokens = tokenize(line);
        if let Some(s) = parse_stmt(&tokens) { ast.push(s); }
    }
    for s in &ast { println!("{:?}", s); }
}
