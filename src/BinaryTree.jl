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

function popat!(tree::AbstractBinaryTree{T}, data::T)::Bool where T
  tree.length -= 1
  parent = nothing
  current = tree.root
  del = current

  while !isnil(current) && dataof(current) != data
    result = tree.compare(dataof(current), data)
    if result > 0
      parent = current
      current = left(current)
    elseif result < 0
      parent = current
      current = right(current)
    end
  end

  if isnil(current)
    return
  end

  if isnil(left(current))
    if current == tree.root
      tree.root = right(current)
    elseif current == left(parent)
      parent.left = right(current)
    else
      parent.right=  right(current)
    end

    del = current
  elseif isnil(right(current))
    if current == tree.root
      tree.root = left(current)
    elseif left(parent) == current
      parent.left == left(current)
    else
      parent.right = left(current)
    end

    del = current
  else
    _left = right(current)
    parent = current
    while !isnil(left(_left))
      parent = _left
      _left = left(_left)
    end

    del = _left
    current.data = dataof(_left)
    if (left(parent) == _left)
      parent.left = right(_left)
    else
      parent.right = right(_left)
    end
  end
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