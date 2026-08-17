page 80001 "REST API Playground"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'REST API Playground';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(GlobalUserId; GlobalUserId)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Caption = 'User Id';
                    ToolTip = 'Specifies the user ID used when calling the sample REST API.';
                }

                field(GlobalResponseText; GlobalResponseText)
                {
                    ApplicationArea = All;
                    Caption = 'Response';
                    MultiLine = true;
                    Editable = false;
                    ToolTip = 'Displays the raw response returned by the REST API.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Get User")
            {
                Caption = 'GET User';
                Image = GetLines;
                ToolTip = 'Sends an HTTP GET request to retrieve a user from the sample REST API.';

                trigger OnAction()
                begin
                    FetchUserData(GlobalUserId, GlobalResponseText);
                end;
            }
            action("Get User and Parse User Name")
            {
                Caption = 'Get User and Parse User Name';
                Image = GetLines;
                ToolTip = 'Fetches the user record for the specified User ID from the REST API and extracts the name field from the JSON response.';

                trigger OnAction()
                begin
                    FetchAndParseUserName(GlobalUserId, GlobalResponseText);
                end;
            }
            action("Post User")
            {
                Caption = 'POST User';
                Image = SendTo;
                ToolTip = 'Sends an HTTP POST request with a JSON payload.';

                trigger OnAction()
                begin
                    CreateUser('Test', 'Test@gmail.com', GlobalResponseText);
                end;
            }
            action("Put User")
            {
                Caption = 'PUT User';
                Image = Edit;
                ToolTip = 'Sends an HTTP PUT request to replace an existing user.';

                trigger OnAction()
                begin
                    ReplaceUser(GlobalUserId, GlobalResponseText);
                end;
            }
            action("Patch User")
            {
                Caption = 'PATCH User';
                Image = EditLines;
                ToolTip = 'Sends an HTTP PATCH request to partially update an existing user.';

                trigger OnAction()
                begin
                    UpdateUserEmail(1, 'Test@gmail.com', GlobalResponseText);
                end;
            }
            action("Delete User")
            {
                Caption = 'DELETE User';
                Image = Delete;
                ToolTip = 'Sends an HTTP DELETE request to remove a user.';

                trigger OnAction()
                begin
                    DeleteUser(GlobalUserId, GlobalResponseText);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(GetUser_Promoted; "Get User") { }
                actionref(GetUserandParseUserName_Promoted; "Get User and Parse User Name") { }
                actionref(PostUser_Promoted; "Post User") { }
                actionref(PutUser_Promoted; "Put User") { }
                actionref(PatchUser_Promoted; "Patch User") { }
                actionref(DeleteUser_Promoted; "Delete User") { }
            }
        }
    }


    procedure FetchUserData(UserId: Integer; var ResponseText: Text)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Url: Text;
    begin
        Url := 'https://jsonplaceholder.typicode.com/users/' + Format(UserId);

        if not Client.Get(Url, Response) then
            Error('The call to the web service failed.');

        if not Response.IsSuccessStatusCode() then
            Error('The web service returned an error message:\\' +
                  'Status code: %1\\' +
                  'Description: %2',
                  Response.HttpStatusCode(),
                  Response.ReasonPhrase());

        Response.Content().ReadAs(ResponseText);

        Message('Data received: %1', ResponseText);
    end;

    procedure FetchAndParseUserName(UserId: Integer; var ResponseText: Text)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        JObject: JsonObject;
        JToken: JsonToken;
        Url: Text;
        Name: Text;
    begin
        Url := 'https://jsonplaceholder.typicode.com/users/' + Format(UserId);

        if not Client.Get(Url, Response) then
            Error('The call to the web service failed.');

        if Response.IsSuccessStatusCode() then begin
            Response.Content().ReadAs(ResponseText);

            if JObject.ReadFrom(ResponseText) then
                if JObject.Get('name', JToken) then begin
                    Name := JToken.AsValue().AsText();
                    Message('The user is: %1', Name);
                end;
        end;
    end;

    procedure CreateUser(Name: Text; EmailId: Text; var ResponseText: Text)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        JObject: JsonObject;
        PayloadText: Text;
    begin
        // 1. Construct the JSON payload
        JObject.Add('name', Name);
        JObject.Add('email', EmailId);
        JObject.WriteTo(PayloadText);

        // 2. Add payload to HttpContent and set Content-Type header
        Content.WriteFrom(PayloadText);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');

        // 3. Prepare the Request Message
        Request.SetRequestUri('https://jsonplaceholder.typicode.com/users');
        Request.Method('POST');
        Request.Content := Content;

        // 4. Send the Request
        if Client.Send(Request, Response) then
            if Response.IsSuccessStatusCode() then begin
                Response.Content().ReadAs(ResponseText);
                Message('User created successfully!');
            end;
    end;

    procedure ReplaceUser(UserId: Integer; var ResponseText: Text)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        JObject: JsonObject;
        PayloadText: Text;
    begin
        // 1. Build the full replacement payload
        JObject.Add('id', UserId);
        JObject.Add('name', 'John Doe Updated');
        JObject.Add('email', 'john.updated@example.com');
        JObject.WriteTo(PayloadText);

        // 2. Attach payload and Content-Type header
        Content.WriteFrom(PayloadText);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');

        // 3. Prepare and send the PUT request
        Request.SetRequestUri('https://jsonplaceholder.typicode.com/users/' + Format(UserId));
        Request.Method('PUT');
        Request.Content := Content;

        if Client.Send(Request, Response) then
            if Response.IsSuccessStatusCode() then begin
                Response.Content().ReadAs(ResponseText);
                Message('User %1 replaced successfully!', UserId);
            end;
    end;

    procedure UpdateUserEmail(UserId: Integer; NewEmail: Text; var ResponseText: Text)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        JObject: JsonObject;
        PayloadText: Text;
    begin
        // 1. Only include the fields you want to change
        JObject.Add('email', NewEmail);
        JObject.WriteTo(PayloadText);

        // 2. Attach payload and Content-Type header
        Content.WriteFrom(PayloadText);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/json');

        // 3. Prepare and send the PATCH request
        Request.SetRequestUri('https://jsonplaceholder.typicode.com/users/' + Format(UserId));
        Request.Method('PATCH');
        Request.Content := Content;

        if Client.Send(Request, Response) then
            if Response.IsSuccessStatusCode() then begin
                Response.Content().ReadAs(ResponseText);
                Message('User %1 updated successfully!', UserId);
            end;
    end;

    procedure DeleteUser(UserId: Integer; var ResponseText: Text)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
    begin
        Request.SetRequestUri('https://jsonplaceholder.typicode.com/users/' + Format(UserId));
        Request.Method('DELETE');

        if Client.Send(Request, Response) then
            if Response.IsSuccessStatusCode() then begin
                Response.Content().ReadAs(ResponseText);
                Message('User %1 deleted successfully!', UserId);
            end;
    end;

    var
        GlobalUserId: Integer;
        GlobalResponseText: Text;
}