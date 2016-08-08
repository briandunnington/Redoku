function init()
	m.top.functionName = "executeTask"
end function

function executeTask()
	request = CreateUrlTransfer("https://www.reddit.com/r/roku.json")
	response = request.GetToString()
	json = ParseJSON(response)

	titles = []
	for i=0 to json.data.children.Count() - 1
		child = json.data.children[i]
		titles.push(child.data.title)
	end for

	'Now that we have retrieved the data, go ahead and dispatch the action.
	AddTodos(titles)
end function

function CreateUrlTransfer(url As String) as Object
    obj = CreateObject("roUrlTransfer")
    obj.SetCertificatesFile("common:/certs/ca-bundle.crt")
    obj.InitClientCertificates()
    obj.SetPort(CreateObject("roMessagePort"))
    obj.SetUrl(url)
    obj.AddHeader("x-roku-reserved-dev-id","dynamicValueToBeInserted")
    obj.EnableEncodings(true)
    obj.RetainBodyOnError(true)
    return obj
end function
