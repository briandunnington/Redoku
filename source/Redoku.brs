'THINGS TO NOTE:
' m.global.state contains the state store (m.global.prevState contains the previous state) and are the only things you should access outside of this file.
' m.global.dispatch contains the dispatched action queue and timer (so that actions can be safely dispatched serially)
' m.reducers live only in the root scene

'Call this from your main() function before you create your root scene.
sub RedokuSetInitialState(initialState as object, screen as object)
    m.global = screen.GetGlobalNode()
    m.global.addFields({
        state: RedokuClone(initialState),
        prevState: {}
    })
end sub

'Call this from your root scene BEFORE you call RedokuInitialize
sub RedokuRegisterReducer(section as string, reducer as function)
    if NOT IsValid(m.reducers) then m.reducers = {}
    m.reducers[section] = reducer
end sub

'Call this from your root scene AFTER you have registered any reducers
sub RedokuInitialize()
    dispatchTimer = createObject("roSGNode", "Timer")
    dispatchTimer.duration = .01
    dispatchTimer.repeat = false
    dispatchTimer.observeField("fire", "RedokuDispatchTimerFired")

    m.global.addFields({
        dispatch: {
            timer: dispatchTimer,
            queue: []
        }
    })

    RedokuDispatch(invalid)
end sub

'Call this from any action creator to trigger a reducer cycle
sub RedokuDispatch(action as object)
    pre = m.global.dispatch.queue.count()
    dispatch = m.global.dispatch
    dispatch.queue.push(action)
    post = m.global.dispatch.queue.count()
    'TODO: come up with a better solution for this.
    'If multiple threads dispatch actions at the same time, there can be a race condition.
    'Since we have to copy the queue, modify it, and copy it back to the global node,
    'it can cause the wrong data to be written.
    'The temporary work-around is to check the queue count at the beginning of the operation
    'and again at the end to see if anybody else has modified the queue in the meantime.
    if NOT post = pre
        RedokuDispatch(action)
        return
    end if
    m.global.dispatch = dispatch

    if(m.global.dispatch.queue.count() > 0)
        m.global.dispatch.timer.control = "start"
    end if
end sub

'Call this from any reducer to clone the state
function RedokuClone(obj as object) as object
    newObj = {}
    if IsValid(obj)
        for each prop in obj
            newObj[prop] = obj[prop]
        end for
    end if
    newObj.__RedokuStateId = Str(Rnd(0))
    return newObj
end function


'-------------------------------------------------------------------------------------
'Do not call the functions below here. They are called internally by the Redoku logic.
'-------------------------------------------------------------------------------------

'Do not call this - it is called automatically when RedokuDispatch is called
sub RedokuDispatchTimerFired()
    dispatch = m.global.dispatch
    if(dispatch.queue.count() > 0)
        action = dispatch.queue.shift()
        m.global.dispatch = dispatch
        RedokuRunReducers(action)
    end if
    ' If there are still events to process, start the timer again.
    if(m.global.dispatch.queue.count() > 0)
        m.global.dispatch.timer.control = "start"
    end if
end sub

'Do not call this - it is called automatically when RedokuDispatch is called
sub RedokuRunReducers(action as object)
    if IsValid(m.reducers)
        didChange = false
        state = m.global.state
        prevState = state
        for each reducerKey in m.reducers
            section = reducerKey
            reducer = m.reducers[reducerKey]
            oldState = state[section]
            newState = reducer(state[section], action)
            if NOT RedokuCompareState(oldState, newState)
                state = RedokuClone(state)
                state[section] = newState
                didChange = true
            end if
        end for
        if didChange
            '?"Redoku: State changed"
            m.global.prevState = prevState
            m.global.state = state
        else
            '?"Redoku: State did not change"
        end if
    end if
end sub

'Do not call this - it is only used to determine if the state has changed
'since Roku does not support object comparison.
function RedokuCompareState(oldState as object, newState as object) as boolean
    'return FormatJSON(oldState) = FormatJSON(newState)

    oldStateIsValid = IsValid(oldState)
    newStateIsValid = IsValid(newState)
    'Equal if:
    'both invalid
    'both valid AND dont have __RedokuStateId
    'both valid AND have __RedokuStateId AND ==
    if NOT oldStateIsValid AND NOT newStateIsValid then return true
    if oldStateIsValid AND newStateIsValid
        if NOT oldState.DoesExist("__RedokuStateId") AND NOT newState.DoesExist("__RedokuStateId") return true
        return oldState.__RedokuStateId = newState.__RedokuStateId
    end if
    'Otherwise, not equal
    return false
end function
