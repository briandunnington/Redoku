function init()
	'register as many reducers as your app requires
	RedokuRegisterReducer("todos", todosReducer)
	RedokuRegisterReducer("visibilityFilter", visibilityFilterReducer)
	'after all reducers are registered, initialize the system
	RedokuInitialize()

	m.top.observeField("focusedChild", "focusChanged")
	m.app = m.top.findNode("app")
	m.top.setFocus(true)
end function

function focusChanged()
	if m.top.hasFocus()
		m.app.setFocus(true)
	end if
end function

'reducers are just like in Redux.
'they should take the current state and action and return the new state.
'if the state has not changed, return it as-is, otherwise clone it with
'RedokuClone() and return an updated copy.
function todosReducer(state as dynamic, action as object) as object
	if IsValid(action)
		if action.type = ActionTypes().ADD_TODO
			items = []
			for i=0 to state.items.Count() - 1
				items.push(state.items[i])
			end for

			items.push({
				text: action.text,
				completed: false
			})
			newState = RedokuClone(state)
			newState.items = items
			return newState
		else if action.type = ActionTypes().ADD_TODOS
			items = []
			for i=0 to state.items.Count() - 1
				items.push(state.items[i])
			end for

			for i=0 to action.titles.Count() - 1
				items.push({
					text: action.titles[i],
					completed: false
				})
			end for
			newState = RedokuClone(state)
			newState.items = items
			return newState
		else if action.type = ActionTypes().REMOVE_TODO
			items = []
			for i=0 to state.items.Count() - 1
				if NOT i = action.index
					items.push(state.items[i])
				end if
			end for

			newState = RedokuClone(state)
			newState.items = items
			return newState
		else if action.type = ActionTypes().TOGGLE_TODO
			items = []
			for i=0 to state.items.Count() - 1
				item = state.items[i]
				if i=action.index
					item = RedokuClone(item)
					item.completed = NOT item.completed
				end if
				items.push(item)
			end for
			newState = RedokuClone(state)
			newState.items = items
			return newState
		end if
	end if
	return state
end function

function visibilityFilterReducer(state as dynamic, action as object) as object
	if IsValid(action)
		if action.type = ActionTypes().SET_VISIBILITY_FILTER
			if NOT state.current = action.filter
				newState = RedokuClone(state)
				newState.current = action.filter
				return newState
			end if
		end if
	end if
	return state
end function
