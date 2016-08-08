function init()
	m.filterLabelList = m.top.findNode("filterLabelList")
	m.filterLabelList.observeField("itemSelected", "filterTodos")

	m.top.observeField("focusedChild", "focusChanged")

	'No need to have a 'render' or listen for stateChange since this component
	'never updates.
end function

function filterTodos()
	filter = m.filterLabelList.content.getChild(m.filterLabelList.itemSelected)
	SetVisibilityFilter(filter.title)
end function

function focusChanged()
	if m.top.hasFocus()
		m.filterLabelList.setFocus(true)
	end if
end function
