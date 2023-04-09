using BinaryTree, Test, LinkedList
using BinaryTree: hasleft, hasright, popat!

@testset "test tree" begin
  tree = BSTree(Int)

  for i in 1:50
    insert!(tree, i)
  end

end

@testset "test tree" begin
  tree = AVLTree(Int)
  bstree = BSTree(Int)
  for i in 1:50
    insert!(tree, i)
    insert!(bstree, i)
  end

  @testset "test search" begin
    node = search(tree, 10)
    println(isnothing(node) ? "nothing" : BinaryTree.dataof(node))
    node = search(tree, -1)
    println(isnothing(node) ? "nothing" : BinaryTree.dataof(node))
  end

  @testset "test contains" begin
    @test contains(tree, 50) == true
    @test contains(tree, -1) == false
  end

  @testset "test findfirst" begin
    node = findfirst(isequal(50), tree)
    println(isnothing(node) ? "nothing" : BinaryTree.dataof(node))

    node = findfirst(isequal(-1), tree)
    println(isnothing(node) ? "nothing" : BinaryTree.dataof(node))
  end

  @testset "test popat" begin
      node = findfirst(isequal(25), tree)
      popat!(tree, 25)
      
      println(tree)

      println(popat!(bstree, 25))
      println(bstree)
      # node = findfirst(isequal(25), tree)
      # println(isnothing(node))
  end

  @testset "test replace" begin
    node = findfirst(isequal(50), tree)
    if !isnothing(node)
      replace!(node, -50)
      println(BinaryTree.dataof(node))
    end
    
  end

  @testset "test filter" begin
    array = filter(x -> x % 2 == 0, tree)
    @show eltype(array)
  end

  @testset "test map" begin
    array = map(x -> x + 1, tree)
    @show eltype(array)

  end

  @testset "test reduce" begin
    @show reduce(+, tree)
  end
end