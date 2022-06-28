using BinaryTree, Test, LinkedList
using BinaryTree: hasleft, hasright
@testset "test tree" begin
  tree = BSTree(Int)

  for i in 1:4
    insert!(tree, i)
  end

  @show tree.root
  @show tree.root.right
  @show tree.root.right.right
  @show tree.root.right.right.right

  queue = Queue(BinaryTreeNode{Int})
  push!(queue, tree.root)
  push!(queue, tree.root.right)
  push!(queue, tree.root.right.right)
  push!(queue, tree.root.right.right.right)
  @show queue
  @show tree
end