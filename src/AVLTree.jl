mutable struct AVLTree{T} <: AbstractBinaryTree{T}
  root::Union{AVLTreeNode{T}, BinaryTreeNil{T}}
  length::Int
  compare::Function
end

AVLTree(T::DataType, compare::Function=-) = AVLTree{T}(BinaryTreeNil(T), 0, compare)

insert!(tree::AVLTree{T}, data::T) where T = begin
  tree.root = insert_avlnode!(tree.root, data, tree.compare)
  tree.length += 1
end

_popvalue!(tree::AVLTree{T}, data::T) where T = begin
  tree.root = delete_avlnode!(tree.root, data, tree.compare)
end

popat!(tree::AVLTree{T}, data::T) where T = begin
  _popvalue!(tree, data)
end