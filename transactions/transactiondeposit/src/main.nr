use dep::std;

struct NodeData {
    nullifier: Field,
    secret: Field,
    address: Field,
    balance: Field
}

fn assertDataValid(nodeData: NodeData, index: Field, hash_path: [Field;3], public_root: Field) {
    let arr: Vec<Field> = Vec::new();
    let node = std::hash::hash_to_field(arr);
    let calculated_root = std::merkle::compute_merkle_root(node, index, hash_path);
    assert(calculated_root == public_root);
} 


// withdraw
fn main(nodeData: NodeData, index: Field, hash_path: [Field;3], public_root: pub Field) {
    assertDataValid(nodeData, index, hash_path, public_root);
}

#[test]
fn test_main() {
}
