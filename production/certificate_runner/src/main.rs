use certificate_runner::{run_all, all_passed};

fn main() {
    let reports = run_all();
    for r in &reports {
        println!("{}", r);
    }
    if all_passed(&reports) {
        println!("ALL {} VECTORS PASSED", reports.len());
        std::process::exit(0);
    } else {
        println!("SOME VECTORS FAILED");
        std::process::exit(1);
    }
}
