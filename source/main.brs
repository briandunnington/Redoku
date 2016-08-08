Library "v30/bslCore.brs"

function Main(args as Dynamic) as void
    if firmwareRequiresUpdate() then return
    showHomeScreen(args)
end function

sub showHomeScreen(args as dynamic)
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

	'Set your initial state before showing your root scene
	'(so that child components can render their initial state)
	initialState = {
		todos: {
			items: [{
				text: "initial task",
				completed: false
			}, {
				text: "second task",
				completed: true
			}]
		},
		visibilityFilter: {
			current: "SHOW_ALL"
		}
	}
	RedokuSetInitialState(initialState, screen)

    ' construct the scene and show it
    m.scene = screen.CreateScene("HomeScene")
    screen.show()
    while(true)
        msg = wait(100, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        endif
    end while
end sub

function firmwareRequiresUpdate() as boolean
    'First firmware release with SceneGraph SDK2.0 support is 6.0.
    majorRequirement = 7
    minorRequirement = 0
    buildRequirement = 0

    'get firmware version
    version = CreateObject("roDeviceInfo").GetVersion()

    major = Mid(version, 3, 1)
    minor = Mid(version, 5, 2)
    build = Mid(version, 8, 5)

    message = "Major Version: " + major + " Minor Version: " + minor + " Build Number: " + build
    ?message

    requiresUpdate = false
    if Val(major) < majorRequirement then
        requiresUpdate = true
    else if Val(major) = majorRequirement then
        if Val(minor) < minorRequirement then
            requiresUpdate = true
        else if Val(minor) = minorRequirement then
            if Val(build) < buildRequirement
                requiresUpdate = true
            endif
        endif
    endif

    if requiresUpdate then showRequiresUpdateScreen()

    return requiresUpdate
end function

sub showRequiresUpdateScreen()
    port = CreateObject("roMessagePort")
    screen = CreateObject("roParagraphScreen")
    screen.SetMessagePort(port)
    screen.AddHeaderText("Roku software update required")
    screen.AddParagraph("In order to use this channel, you must update the software on your Roku player.  To update your software:")
    screen.AddParagraph("1.  Select " + chr(34) + "settings" + chr(34) + " from the Roku home screen.")
    screen.AddParagraph("2.  Select " + chr(34) + "player info." + chr(34))
    screen.AddParagraph("3.  Select " + chr(34) + "check for update." + chr(34))
    screen.AddParagraph("4.  Select " + chr(34) + "yes." + chr(34))
    screen.AddParagraph("5. Once your Roku player has finished updating, you may use this channel.")
    screen.AddButton(1, "back")
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roParagraphScreenEvent"
            if msg.isScreenClosed()
                ?"Main.brs | Screen closed"
            else if msg.isButtonPressed()
                ?"Main.brs | Button pressed: "
            else
                ?"Main.brs | Unknown event: "
            endif
            exit while
        endif
    end while
end sub
