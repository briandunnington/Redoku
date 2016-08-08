function IsInvalid(val as dynamic) as boolean
    return type(val) = type(idontexistpleasedontcreateme) OR type(val) = "roInvalid" OR type(val) = "Invalid"
end function

function IsValid(val as dynamic) as boolean
    return NOT IsInvalid(val)
end function
