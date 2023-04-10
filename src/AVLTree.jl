mutable struct AVLTree{T} <: AbstractBinaryTree{T}
  root::Union{AVLTreeNode{T}, BinaryTreeNil{T}}
  length::Int
  compare::Function
end

AVLTree(T::DataType, compare::Function=-) = AVLTree{T}(BinaryTreeNil(T), 0, compare)

haskey(tree::AVLTree{T}, data::T) where T = begin
  isnil(tree.root) && return false

  node = search(data, tree)
  return !isnil(node)
end

insert!(tree::AVLTree{T}, data::T) where T = begin
  tree.root = insert_avlnode!(tree.root, data, tree.compare)
  tree.length += 1
end

popat!(tree::AVLTree{T}, data::T) where T = begin
  if haskey(tree, data)
    tree.root = delete_avlnode!(tree.root, data, tree.compare)
    tree.length -= 1
  end
end
  