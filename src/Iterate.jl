abstract type BinaryTreeIterator{T} end

struct LevelOrderIterator{T} <: BinaryTreeIterator{T}
  node::BinaryTreeNode{T}
  length::Int
end

struct PreOrderIterator{T} <: BinaryTreeIterator{T}
  node::BinaryTreeNode{T}
  length::Int
end

mutable struct InOrderIterator{T} <: BinaryTreeIterator{T}
  node::BinaryTreeNode{T}
  length::Int
end

struct PostOrderIterator{T} <: BinaryTreeIterator{T}
  node::BinaryTreeNode{T}
  length::Int
end

length(iterator::BinaryTreeIterator) = iterator.length
levelorder(tree::AbstractBinaryTree{T}) where T = LevelOrderIterator{T}(tree.root, length(tree))
preorder(tree::AbstractBinaryTree{T}) where T = PreOrderIterator{T}(tree.root, length(tree))

postorder(tree::AbstractBinaryTree{T}) where T = PostOrderIterator{T}(tree.root, length(tree))

inorder(tree::AbstractBinaryTree{T}) where T = InOrderIterator{T}(tree.root, length(tree))

function iterate(iterator::LevelOrderIterator{T}) where T
  node = iterator.node
  
  isnil(node) && return nothing

  queue = Queue(BinaryTreeNode{T})
  # queue = BinaryTreeNode{T}[]

  if hasleft(node)
    push!(queue, left(node))
  end
  
  if hasright(node)
    push!(queue, right(node))
  end
  
  return node, queue
  
end

function iterate(::LevelOrderIterator{T}, queue::Queue{BinaryTreeNode{T}}) where T
  isempty(queue) && return nothing

  current = first(queue)
  pop!(queue)
  
  if hasleft(current)
    push!(queue, left(current))
  end
  
  if hasright(current)
    push!(queue, right(current))
  end

  # popfirst!(queue)

  return current, queue
end

function iterate(iterator::PreOrderIterator{T}) where T
  node = iterator.node
  if isnil(node)
    return nothing
  else
    stack = Stack(BinaryTreeNode{T})
    push!(stack, node)
    
    current = top(stack)
    pop!(stack)

    if hasright(current)
      push!(stack, right(current))
    end
    
    if hasleft(current)
      push!(stack, left(current))
    end

    return current, stack
  end
end

function iterate(::PreOrderIterator{T}, stack::Stack{BinaryTreeNode{T}}) where T
  if !isempty(stack)
    current = top(stack)
    pop!(stack)

    if hasright(current)
      push!(stack, right(current))
    end
    
    if hasleft(current)
      push!(stack, left(current))
    end
    

    return current, stack

  else
    return nothing
  end
end

function iterate(iterator::PostOrderIterator{T}) where T
  node = iterator.node
  if isnil(node)
    return nothing
  else
    stack = Stack(BinaryTreeNode{T})
    push!(stack, node)
    
    current = top(stack)
    pop!(stack)

    if hasleft(current)
      push!(stack, left(current))
    end
    
    if hasright(current)
      push!(stack, right(current))
    end
    
    return current, stack
  end
end

function iterate(::PostOrderIterator{T}, stack::Stack{BinaryTreeNode{T}}) where T
  if !isempty(stack) 
    current = top(stack)
    pop!(stack)
    
    if hasleft(current)
      push!(stack, left(current))
    end
    
    if hasright(current)
      push!(stack, right(current))
    end
    
    return current, stack
  else
    return nothing
  end
end

function iterate(iterator::InOrderIterator{T}) where T
  current = iterator.node
  isnil(current) && return nothing
  
  stack = Stack(BinaryTreeNode{T})
  while !isnil(current)
    push!(stack, current)
    current = left(current)
  end

  result = top(stack)
  pop!(stack)
  
  # assign back
  iterator.node = right(result)
  # return statement

  return result, stack
end

function iterate(iterator::InOrderIterator{T}, stack::Stack{BinaryTreeNode{T}}) where T
  current = iterator.node
  isnil(current) && isempty(stack) && return nothing

  while !isnil(current)
    push!(stack, current)
    current = left(current)
  end

  result = top(stack)
  pop!(stack)
  # assign back
  iterator.node = right(result)
  # return
  return result, stack
end