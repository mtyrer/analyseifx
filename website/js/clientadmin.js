var currClient="none";
var currHost="none";
var currInstance="none";
var currInstanceID=0;
var InstanceSet=$.Deferred();
var DateSet=$.Deferred();
var currDate="none";
var currGraph="";
var graphs;
var currSeries;
var lastButton;
var editAction="none";


$(document).ready(function () {
    // Step one - populate the drop downs with the first available client, host and instance

    populateClients();
    
    $(document).on("click", ".item_group", function () {
        var id = $(this).parent().attr('id');
        var value = $(this).text();
        $(this).siblings().removeClass("active");
        $(this).addClass("active");
        lastButton = $(this);

        console.log(id);
        switch (id) {
        case 'clients':
            //if (currClient != value) {
                setCurrClient(value);
            //}
            break;
        case 'hosts':
            //if (currHost != value) {
                setCurrHost(value);
            //}
            break;
        case 'instances':
            //if (currInstance != value) {
                var instID = $(this).data("id");  
                setCurrInstance(value, instID);
            //}
            break;
        case 'dates':
            
            //if (currDate != value) {
                //var fileID = $(this).data("id");  
                setCurrDate(value);
            //}
            break;
        }
    });
    
    $("#delete").click(function() {
        if (lastButton) {
            console.log(lastButton.html());
            var id = $(lastButton).parent().attr('id');
            console.log ("id: " + id);
            switch (id) {
            case 'clients':
                console.log("Delete client:" + lastButton.html() );
                delete_client(lastButton.html());                        
                break;
            case 'hosts':
                console.log("Delete host:" + lastButton.html() + " for " + currClient);          
                delete_host(lastButton.html());
                break;
            case 'instances':
                var instID = lastButton.data("id");  
                console.log("Delete instance:" + lastButton.html() + " on " + currHost + " for " + currClient);        
                delete_instance(lastButton.html());
                break;
            case 'dates':
                //console.log("Delete " + lastButton.html() + " from instance " + currInstance + " on " + currHost + " for " + currClient);    
                delete_date(lastButton.data('id'));
                break;
            } 
        }
    });

    $("#edit").click(function() {
        if (lastButton) {
            console.log(lastButton.html());
            var id = $(lastButton).parent().attr('id');
            console.log ("id: " + id);
            switch (id) {
            case 'clients':
                console.log("Update client:" + lastButton.html() );
                set_update_client(lastButton.html());                        
                break;
            case 'hosts':
                console.log("Update host:" + lastButton.html() + " for " + currClient);          
                set_update_host(lastButton.html());
                break;
            case 'instances':
                var instID = lastButton.data("id");  
                console.log("Update instance:" + lastButton.html() + " on " + currHost + " for " + currClient);        
                set_update_instance(lastButton.html());
                break;
            case 'dates':
                //console.log("Update " + lastButton.html() + " from instance " + currInstance + " on " + currHost + " for " + currClient);    
                //update_date(lastButton.data('id'));
                break;
            } 
        }
    });

    $("#edit_submit").click(function () {
        var newval;
        switch (editAction) {
            case 'instance' :
                newval=$("#instance_txt").val();
                if (newval == currInstance) {
                    console.log("no change");
                } else {
                    console.log("instance " + newval);
                    update_instance(newval);
                }
                break;
        }
        
        hide_edit();
        buttons_show();
        
    });

    $("#edit_cancel").click(function () {
        hide_edit();
        buttons_show();
    });
});

function populateClients() {

    $("#clients").html("");    
    $("#hosts").html("");
    $("#instances").html("");
    $("#dates").html("");

    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/client/clients", function (data) {
        
    } ).done (function (data, json) {
        var html = "";
        var first=true;

        $.each (data, function(key, val) {
            //<button type="button" class="list-group-item list-group-item-action">Cras justo odio</button>
            if (first) {
            
                html += ' <button type="button" class="list-group-item list-group-item-action item_group active" data-id="' + val.id + '">' + 
                    val.client_name  + '</button>';

                first = false;
            } else {
                html += ' <button type="button" class="list-group-item list-group-item-action item_group" data-id="' + val.id + '">' + 
                    val.client_name  + '</button>';
            }
        }) ;

        $("#clients").html(html);    
        setCurrClient(data[0].client_name);
        
    } ).fail (function ( jqxhdr, textStatus, error) {
        //console.log(textStatus, error, jqxhdr);
    });
}

function setCurrClient(client) {

    currClient = client;

    populateHost();
}

function populateHost() {

    $("#hosts").html("");
    $("#instances").html("");
    $("#dates").html("");

    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/host/hosts/"+currClient, function (data) {
        
    } ).done (function (data, json) {
        var html = "";
        var first=false;
        
        $.each (data, function(key, val) {
            //html += '<a class="dropdown-item dditem" href="#">' + val["host_name"]  + '</a>';
            if (first) {

                html += ' <button type="button" class="list-group-item list-group-item-action item_group active" data-id="' + val.id + '">' + 
                    val.host_name  + '</button>';

                first = false;
            } else {
              html += ' <button type="button" class="list-group-item list-group-item-action item_group" data-id="' + val.id + '">' + 
                val.host_name  + '</button>';
            }
        });

        $("#hosts").html(html);
        
        setCurrHost(data[0].host_name);

    } ).fail (function ( jqxhdr, textStatus, error) {
        //console.log(textStatus, error, jqxhdr);
    });
}

function setCurrHost(host) {

    currHost = host;

    populateInstance();

}

function populateInstance() {

    $("#instances").html("");
    $("#dates").html("");

    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/instance/instances/" + currHost, function (data) {
        
    } ).done (function (data, json) {
        var html = "";
        var first = false;
       
        $.each (data, function(key, val) {

            if (first) {
                html += ' <button type="button" class="list-group-item list-group-item-action item_group active" data-id="' + val.id + '">' + 
                val.instance_name  + '</button>';
                first=false;
            } else {
                html += ' <button type="button" class="list-group-item list-group-item-action item_group" data-id="' + val.id + '">' + 
                val.instance_name  + '</button>';
            }
        }) ;
        //console.log(html);
        $("#instances").html(html);
        setCurrInstance(data[0].instance_name, data[0].id);
        
    } ).fail (function ( jqxhdr, textStatus, error) {
        //console.log(textStatus, error, jqxhdr);
    });
}

function setCurrInstance(instance, instanceID) {
    currInstance = instance;
    currInstanceID = instanceID;

    InstanceSet.resolve();
    populateDates();
}

function populateDates() {

    $("#dates").html("");

    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/date/dates/" + currInstanceID, function (data) {
        
    } ).done (function (data) {
        var html = "";
        var first = false;
        var retdate;
        //console.log("date: " + data[0]);    
        $.each (data, function(key, val) {

            var setdate=val;
            if (first) {
                html += ' <button type="button" class="list-group-item list-group-item-action item_group active">' + 
                setdate  + '</button>';
                first = false;
                retdate = setdate;
            } else {
                html += ' <button type="button" class="list-group-item list-group-item-action item_group">' + 
                setdate  + '</button>';
            }

        });

        $("#dates").html(html);

        setCurrDate(retdate);

    } ).fail (function ( jqxhdr, textStatus, error) {
        //console.log(textStatus, error, jqxhdr);
        setCurrDate(null);
    });
}

function setCurrDate(setdate) {
 
    currDate = setdate;
   
    $("#btndate").text("Date : " + currDate + " ");

    DateSet.resolve();
    
}

function delete_client(InstanceElement) {

    //
    // gather the required information to delete.  
    // the following is require in order to delete for the date
    //
    
    var proceed = confirm("Delete the client for real? :" + currClient );

    if (proceed) {
        // remove
        $.ajax({
            url: 'http://localhost/analyseifx/webserver/index.php/api/client/client/' + currClient,
            type: 'DELETE'
        }).done (function (data) {
            alert('The Client has left the house!!');
            //console.log (data[0]);            
            populateClients();
        }).fail (function ( jqxhdr, textStatus, error) {
            console.log(textStatus, error, jqxhdr);
        });    
    }


}

function delete_date(dateElement) {
    
    // gather the required information to delete.  
    // the following is require in order to delete for the date
    //
    
    var proceed = confirm("Delete the data for real? :" + currDate + " on " + currInstance );
    
    if (proceed) {
        // remove
        $.ajax({
            url: 'http://localhost/analyseifx/webserver/index.php/api/date/date/' + currInstanceID + "/" + currDate,
            type: 'DELETE'
        }).done (function (data) {
            alert('File has left the house!!');
            //console.log (data[0]);            
            populateDates();
        }).fail (function ( jqxhdr, textStatus, error) {
            console.log(textStatus, error, jqxhdr);
        });    
    }
}

function delete_host(InstanceElement) {
    
    // gather the required information to delete.  
    // the following is require in order to delete for the date
    //
    
    var proceed = confirm("Delete the host for real? :" + currHost );

    if (proceed) {
        // remove
        $.ajax({
            url: 'http://localhost/analyseifx/webserver/index.php/api/host/host/' + currClient + "/" + currHost,
            type: 'DELETE'
        }).done (function (data) {
            alert('File has left the house!!');
            //console.log (data[0]);            
            populateHost();
        }).fail (function ( jqxhdr, textStatus, error) {
            console.log(textStatus, error, jqxhdr);
        });    
    }
}

function delete_instance(InstanceElement) {
    
    // gather the required information to delete.  
    // the following is require in order to delete for the date
    
    var proceed = confirm("Delete the instance for real? :" + currInstance );

    if (proceed) {
        // remove
        $.ajax({
            url: 'http://localhost/analyseifx/webserver/index.php/api/instance/instance/' + currInstanceID,
            type: 'DELETE'
        }).done (function (data) {
            alert('File has left the house!!');
            //console.log (data[0]);            
            populateInstance();
        }).fail (function ( jqxhdr, textStatus, error) {
            console.log(textStatus, error, jqxhdr);
        });    
    }
}

function set_update_instance(InstanceElement) {

    // gather the required information to delete.  
    // the following is require in order to delete for the date

    editAction = "instance";

    $("#inputcustomer").hide();
    $("#inputhost").hide();
    $("#inputinstance").show();
    $("#instance_txt").val(currInstance);

    show_edit("instance");
}
 
function update_instance(instance_name) {

    $.post('http://localhost/analyseifx/webserver/index.php/api/instance/instance/', 
        {action:'update', id:currInstanceID, name:instance_name})
        .done (function (data) {
            alert('instance has been updated!!');
            //console.log (data[0]);            
            populateInstance();
        }).fail (function ( jqxhdr, textStatus, error) {
            console.log(textStatus, error, jqxhdr);
        });    

}

function show_edit(edit) {

    $("#modifyform").show();
    buttons_hide();
}

function hide_edit() {
    $("#modifyform").hide();
    buttons_show();
}

function buttons_hide() {
    $("#actions").hide();
}

function buttons_show() {
    $("#actions").show();
}
