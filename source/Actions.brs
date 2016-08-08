'Actions and action creators are just like in Redux.
'Actions should have a 'type' property and you dispatch them with RedokuDispatch()

function AddTodo(text as string)
	RedokuDispatch({
		type: ActionTypes().ADD_TODO,
		text: text
	})
end function

function RemoveTodo(index as integer)
	RedokuDispatch({
		type: ActionTypes().REMOVE_TODO,
		index: index
	})
end function

function ToggleTodo(index as integer)
	RedokuDispatch({
		type: ActionTypes().TOGGLE_TODO,
		index: index
	})
end function

function AddTodos(titles as object)
	RedokuDispatch({
		type: ActionTypes().ADD_TODOS,
		titles: titles
	})
end function

function SetVisibilityFilter(filter as string)
	RedokuDispatch({
		type: ActionTypes().SET_VISIBILITY_FILTER,
		filter: filter
	})
end function
