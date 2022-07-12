module BinaryTree

import Base: eltype, show, iterate, insert!, keys, contains, length, popat!, replace!, filter
import Base.:(==)

using LinkedList
include("TreeNode.jl")

abstract type AbstractBinaryTree{T} end

eltype(::Type{<:AbstractBinaryTree{T}}) where T = T
eltype(::Type{Base.Iterators.Filter{F, V}}) where {F, V} = eltype(V)

length(tree::AbstractBinaryTree) = tree.length

keys(tree::AbstractBinaryTree{T}) where T = LevelOrderIterator{T}(tree.root, length(tree))
# iterate Tree should return value
function iterate(tree::AbstractBinaryTree{T}) where T
  node = tree.root
  
  isnil(node) && return nothing
  # queue = Queue(BinaryTreeNode{T})
  queue = BinaryTreeNode{T}[]

  if hasleft(node)
    push!(queue, left(node))
  end
  
  if hasright(node)
    push!(queue, right(node))
  end
  
  return dataof(node), queue

end

function iterate(::AbstractBinaryTree{T}, queue::Vector{BinaryTreeNode{T}}) where T
  isempty(queue) && return nothing

  # else
  current = first(queue)
  
  if hasleft(current)
    push!(queue, left(current))
  end
  
  if hasright(current)
    push!(queue, right(current))
  end
  
  popfirst!(queue)
  return dataof(current), queue
end

# show and filter
show(io::IO, tree::AbstractBinaryTree) = begin
  for value in tree
    print(io, value, " ")
  end
end

filter(testf::Function, tree::AbstractBinaryTree{T}) where T = begin
  Iterators.filter(testf, tree) |> collect
end

function search(value::T, tree::AbstractBinaryTree{T}) where T
  compare = tree.compare
  current = tree.root
  
  while !isnil(current)
    result = compare(value, dataof(current))
    if result > 0
      current = right(current)
    elseif result < 0
      current = left(current)
    else
      break
    end
  end

  return isnil(current) ? nothing : current
  
end

popat!(tree::AbstractBinaryTree, node::BinaryTreeCons) = begin
  tree.length -= 1
  tree.root = _popat!(tree, node)
end

function _popat!(tree::AbstractBinaryTree{T}, node::BinaryTreeCons{T}) where T
  targetnode = node # target for delete

  backfather, status = _find_node(tree.root, node.data) 
  if isnil(backfather)
    return backfather
  end
  
  if status == -1
    targetnode = left(backfather)
  elseif status == 1
    targetnode = right(backfather)
  elseif status == 0
    targetnode = backfather
  end
  
  # 第一中情况，没有左子树
  if isnil(left(targetnode))
    if backfather != targetnode
      backfather.right = right(targetnode)
    else
      tree.root = right(tree.root)
    end
    
    targetnode = BinaryTreeNil(T)
    return tree.root
  end
  
  # 第二种情况，没有右子树
  if isnil(right(targetnode))
    if backfather != targetnode
      backfather.left = left(targetnode)
    else
      tree.root = left(tree.root)
    end
    
    targetnode = BinaryTreeNil(T)
    return tree.root
  end
  
  # 第三种情况，有左子树和右子树
  backfather = targetnode
  nextnode = left(targetnode)
  while !isnil(right(nextnode)) 
    backfather = nextnode
    nextnode = right(nextnode)
  end
  
  targetnode.data = dataof(nextnode)
  
  if left(backfather) == nextnode
    backfather.left = left(nextnode)
  else
    backfather.right = right(nextnode)
  end
  
  return tree.root
end



function search(tree::AbstractBinaryTree{T}, target::T) where T
  current = tree.root
  compare = tree.compare
  while !isnil(current)
    result = compare(dataof(current), target)
    if result == 0
      return current
    elseif result < 0
      current = right(current)
    else
      current = left(current)
    end
  end

  return isnil(current) ? nothing : current                # now return nil
end

function contains(tree::AbstractBinaryTree{T}, data::T) where T
  node = tree.root
  compare = tree.compare
  
  while !isnil(node)
    result = compare(data, dataof(node))

    if result == 0
      return true
    elseif result > 0 
      node = right(node)
    else 
      node = left(node)
    end
  end
  
  return false
end

include("Iterate.jl")
include("BSTree.jl")
include("AVLTree.jl")


export BSTree, BinaryTreeNode, insert!, popat!,
  length, levelorder, preorder, inorder, postorder, dataof,
  left, right, isleaf, isnil, search

export AVLTree
end