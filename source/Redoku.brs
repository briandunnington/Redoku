'Call this from your main() function before you create your root scene.
function RedokuSetInitialState(initialState as object, screen as object)
	m.global = screen.GetGlobalNode()
	m.global.addFields({
		state: RedokuClone(initialState),
		dispatch: {}
	})
end function

'Call this from your root scene BEFORE you call RedokuInitialize
function RedokuRegisterReducer(section as string, reducer as function)
	if NOT IsValid(m.reducers) then m.reducers = {}
	m.reducers[section] = reducer
end function

'Call this from your root scene AFTER you have registered any reducers
function RedokuInitialize()
	m.global.observeField("dispatch", "RedokuDispatchWatcher")
	RedokuDispatch(invalid)
end function

'Call this from any action creator to trigger a reducer cycle
function RedokuDispatch(action as object)
	m.global.dispatch = action
end function

'Do not call this - it is called automatically when RedokuDispatch is called
function RedokuDispatchWatcher()
	if IsValid(m.reducers)
		didChange = false
		action = m.global.dispatch
		state = m.global.state
		for each reducerKey in m.reducers
			section = reducerKey
			reducer = m.reducers[reducerKey]
			oldState = state[section]
			newState = reducer(state[section], action)
			if NOT RedokuCompareState(oldState, newState)
				state.AddReplace(section, newState)
				didChange = true
			end if
		end for
		if didChange
			?"State changed"
			m.global.state = state
		else
			?"State did not change"
		end if
	end if
end function

'Call this from any reducer to clone the state
function RedokuClone(obj as object) as object
	newObj = {}
	for each prop in obj
		newObj[prop] = obj[prop]
	end for
	newObj.__RedokuStateId = Str(Rnd(0))
	return newObj
end function

'Do not call this - it is only used to determine if the state has changed
'since Roku does not support object comparison.
function RedokuCompareState(oldState as object, newState as object) as boolean
	'return FormatJSON(oldState) = FormatJSON(newState)

	if IsInvalid(oldState) then oldState = {}
	if IsInvalid(newState) then newState = {}
	return oldState.__RedokuStateId = newState.__RedokuStateId
end function
