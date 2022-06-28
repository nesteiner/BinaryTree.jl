mutable struct BSTree{T} <: AbstractBinaryTree{T}
  root::BinaryTreeNode{T}
  compare::Function
  length::Int
end

BSTree(T::DataType, compare::Function = -) = BSTree{T}(BinaryTreeNil(T), compare, 0)
# MODULE 添加数据
insert!(tree::BSTree{T}, data::T) where T = begin
  tree.root = insert_node!(tree.root, data, tree.compare)
  tree.length += 1
end

# MODULE 删除数据
# already exists
# MODULE 修改数据
# already exists
# MODULE 查找数据
findnode(tree::AbstractBinaryTree{T}, data::T) where T = _find_node(tree.root, data, tree.compare)
# MODULE 转换
# already exists, using collect(iterate(tree)), collect(preorder(tree)) e.g.