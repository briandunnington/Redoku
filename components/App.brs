function init()
	m.todoList = m.top.findNode("todoList")
	m.filters = m.top.findNode("filters")
	m.task = CreateObject("roSGNode", "RedditTask")
	m.top.observeField("focusedChild", "focusChanged")
end function

function focusChanged()
	if m.top.hasFocus()
		m.todoList.setFocus(true)
	end if
end function

function onKeyEvent(key as string, press as boolean) as boolean
	if press
		if key = "right"
			m.filters.setFocus(true)
		else if key = "left"
			m.todoList.setFocus(true)
		else if press and key = "options"
			m.task.control = "run"
			handled = true
		end if
	end if
end function
