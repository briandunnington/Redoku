function init()
	m.todoLabelList = m.top.findNode("todoLabelList")
	m.todoLabelList.observeField("itemSelected", "toggleTodoCompletion")
	m.top.observeField("focusedChild", "focusChanged")

	'watch for state changes and re-render as necessary
	m.global.observeField("state", "stateChanged")
	'render initial state
	render()
end function

function stateChanged()
	render()
end function

function render()
?"TodoList was re-rendered due to state change"
	focusIndex = m.todoLabelList.itemFocused
	content = CreateObject("roSGNode", "ContentNode")
	showAll = m.global.state.visibilityFilter.current = "SHOW_ALL"
	for i=0 to m.global.state.todos.items.Count() - 1
		todo = m.global.state.todos.items[i]
		if todo.completed or showAll
			child = content.createChild("ContentNode")
			child.title = todo.text
			if todo.completed then child.title = "X " + child.title
		end if
	end for
	m.todoLabelList.content = content
	m.todoLabelList.jumpToItem = focusIndex
end function

'trigger various actions based on user input (key presses)
function onKeyEvent(key as string, press as boolean) as boolean
	handled = false
	if press and key = "play"
		AddTodo(CreateObject("roDateTime").ToISOString())
		handled = true
	else if press and key = "replay"
		RemoveTodo(m.todoLabelList.itemFocused)
		handled = true
	end if
	return handled
end function

function toggleTodoCompletion()
	todoIndex = m.todoLabelList.itemSelected
	ToggleTodo(todoIndex)
end function

function focusChanged()
	if m.top.hasFocus()
		m.todoLabelList.setFocus(true)
	end if
end function
