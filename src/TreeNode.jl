abstract type BinaryTreeNode{T} end

mutable struct BinaryTreeNil{T} <: BinaryTreeNode{T} end

mutable struct BinaryTreeCons{T} <: BinaryTreeNode{T}
  data::T
  left::Union{BinaryTreeCons{T}, BinaryTreeNil{T}}
  right::Union{BinaryTreeCons{T}, BinaryTreeNil{T}}
end

mutable struct AVLTreeNode{T} <: BinaryTreeNode{T}
  data::T
  left::Union{AVLTreeNode{T}, BinaryTreeNil{T}}
  right::Union{AVLTreeNode{T}, BinaryTreeNil{T}}
  height::Int
end

BinaryTreeNil(T::DataType) = BinaryTreeNil{T}()
BinaryTreeCons(data::T) where T = BinaryTreeCons{T}(data, BinaryTreeNil(T), BinaryTreeNil(T))
AVLTreeNode(data::T) where T = AVLTreeNode{T}(data, BinaryTreeNil(T), BinaryTreeNil(T), 0)

==(::BinaryTreeNode, ::BinaryTreeNode) = false
==(leftnode::BinaryTreeNil, rightnode::BinaryTreeNil) = true
==(leftnode::BinaryTreeCons, rightnode::BinaryTreeCons) =
  dataof(leftnode) == dataof(rightnode) &&
  left(leftnode) == left(rightnode) &&
  right(leftnode) == right(rightnode)
==(leftnode::AVLTreeNode, rightnode::AVLTreeNode) =
  dataof(leftnode) == dataof(rightnode) &&
  left(leftnode) == left(rightnode) &&
  right(leftnode) == right(rightnode)


show(io::IO, ::BinaryTreeNil) = print(io, "treenil")
show(io::IO, treecons::BinaryTreeCons) = print(io, "treenode: ", dataof(treecons))



dataof(treenode::BinaryTreeNode) = treenode.data
eltype(::BinaryTreeNode{T}) where T = T
left(treenode::BinaryTreeNode) = treenode.left
right(treenode::BinaryTreeNode) = treenode.right
isnil(node::BinaryTreeNode) = isa(node, BinaryTreeNil)
isleaf(treecons::BinaryTreeNode) = isnil(left(treecons)) && isnil(right(treecons))
hasleft(treecons::Union{BinaryTreeNode, AVLTreeNode}) = !isnil(left(treecons))
hasright(treecons::Union{BinaryTreeNode, AVLTreeNode}) = !isnil(right(treecons))



# insert!(::BinaryTreeNil{T}, data::T, compare::Function) where T = BinaryTreeCons(data)

insert_node!(::BinaryTreeNil{T}, data::T, compare::Function) where T = BinaryTreeCons(data)
insert_node!(treecons::BinaryTreeCons{T}, data::T, compare::Function) where {T, NodeType} = begin
  if compare(data, dataof(treecons)) < 0
    treecons.left = insert_node!(left(treecons), data, compare)
  else
    treecons.right = insert_node!(right(treecons), data, compare)
  end

  return treecons
end


iterate(::BinaryTreeNil) = nothing
iterate(node::BinaryTreeNode) where T = begin
  queue = Queue(BinaryTreeNode{T})
  
  if hasleft(node)
    push!(queue, left(node))
  end

  if hasright(node)
    push!(queue, right(node))
  end

  return node, queue
end

iterate(::BinaryTreeCons, queue::Queue{<:BinaryTreeNode}) = begin
  if isempty(queue)
    return nothing
  else
    current = pop!(queue)
    if hasleft(current)
      push!(queue, left(current))
    end

    if hasright(current)
      push!(queue, right(current))
    end

    return current, queue
  end
end

replace!(treecons::BinaryTreeNode{T}, data::T) where T =
  treecons.data = data

function _find_node(node::BinaryTreeNode{T}, data::T, compare::Function) where T
  backfather = node
  status = 0
  result = compare(dataof(node), data)

  while !isnil(node)
    if result == 0
      return backfather, status
    else
      backfather = node

      if result > 0
        node = left(node)
        status = -1
      else
        node = right(node)
        status = 1
      end
    end
  end
  
  return BinaryTreeNil(T)
end


height(::BinaryTreeNil) = 0
height(node::AVLTreeNode) = node.height
balanceFactor(::BinaryTreeNil) = 0
balanceFactor(node::AVLTreeNode) = height(left(node)) - height(right(node))

rotateLeftLeft!(node::AVLTreeNode) = begin
  rightnode = right(node)
  leftnode = left(rightnode)

  rightnode.left = node
  node.right = leftnode

  node.height = max(height(left(node)), height(right(node))) + 1
  rightnode.height = max(height(left(rightnode)), height(right(rightnode))) + 1

  return rightnode
end

rotateRightRight!(node::AVLTreeNode) = begin
  leftnode = left(node)
  @show node
  @show leftnode

  rightnode = right(leftnode)

  leftnode.right = node
  node.left = rightnode

  node.height = max(height(left(node)), height(right(node))) + 1
  leftnode.height = max(height(left(leftnode)), height(right(leftnode))) + 1

  return leftnode
end

rotateLeftRight!(node::AVLTreeNode) = begin
  node.left = rotateRightRight!(left(node))
  return rotateLeftLeft!(node)
end

rotateRightLeft!(node::AVLTreeNode) = begin
  node.right = rotateLeftLeft!(right(node))
  return rotateRightRight!(node)
end

rebalance!(node::AVLTreeNode) = begin
  factor = balanceFactor(node)
  if factor > 1 && balanceFactor(left(node)) > 0
    return rotateRightRight!(node)
  elseif factor > 1 && balanceFactor(left(node)) <= 0
    #= node.left = rotateLeftLeft!(left(node))
    return rotateRightRight!(node) =#
    return rotateLeftRight!(node)
  elseif factor < -1 && balanceFactor(right(node)) <= 0
    return rotateLeftLeft!(node)
  elseif factor < -1 && balanceFactor(right(node)) > 0
    #= node.right = rotateRightRight!(right(node))
    return rotateLeftLeft!(node) =#
    return rotateRightLeft!(node)
  else
    return node
  end
end

insert_avlnode!(::BinaryTreeNil{T}, data::T, compare::Function) where T = AVLTreeNode(data)
insert_avlnode!(node::AVLTreeNode{T}, data::T, compare::Function) where T = begin
  result = compare(data, dataof(node))
  if result > 0
    node.right = insert_avlnode!(right(node), data, compare)
  elseif result < 0
    node.left = insert_avlnode!(left(node), data, compare)
  else
    return node
  end
  
  node.height = max(height(left(node)), height(right(node))) + 1
  node = rebalance!(node)
  return node

end

function delete_avlnode!(node::AVLTreeNode{T}, data::T, compare::Function)::AVLTreeNode{T} where T
  result = compare(data, dataof(node))
  if result < 0
    node.left = delete_avlnode!(left(node), data, compare)
  elseif result > 0
    node.right = delete_avlnode!(right(node), data, compare)
  else
    if !hasleft(node) || !hasright(node)
      temp = BinaryTreeNil(T)
      if (temp == left(node))
        temp = right(node)
      else
        temp = left(node)
      end

      if isnil(temp)
        temp = node
        node = BinaryTreeNil(T)
      else
        node = temp
      end
    else
      temp = minValudNode(right(node))
      node.data = dataof(temp)
      node.right = delete_avlnode!(right(node), dataof(temp), compare)
    end
  end

  if isnil(node)
    return node
  end

  node.height = max(height(left(node)), height(right(node))) + 1
  return rebalance!(node)
end

delete_avlnode!(node::BinaryTreeNil{T}, ::T, ::Function) where T = node

function minValudNode(node::Union{AVLTreeNode, BinaryTreeNil})
  current = node
  while !isnil(current) && !isnil(left(current))
    current = left(current)
  end

  return current
end

show(io::IO, node::AVLTreeNode) = 
  print(io, "(data: $(dataof(node)), left: $(left(node)), right: $(right(node)))")