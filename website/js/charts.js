var currClient="none";
var currHost="none";
var currInstance="none";
var currInstanceID=0;
var InstanceSet=$.Deferred();
var DateSet=$.Deferred();
var currDate="none";
var currGraph="";
var graphs;
//var currSeries;


$(document).ready(function () {
    // Step one - populate the drop downs with the first available client, host and instance
    
    load_sidebar();
    
    // get - clients
    populateClients();
    
    $(document).on("click", ".dditem", function () {
        var id = $(this).parent().attr('id');
        var value = $(this).text();

        //console.log(id);
        switch (id) {
            case 'ddclient':
                if (currClient != value) {
                    setCurrClient(value);
                }
                break;
            case 'ddhost':
                if (currHost != value) {
                    setCurrHost(value);
                }
                break;
            case 'ddinstance':
                if (currInstance != value) {
                    var instID = $(this).data("id");  
                    setCurrInstance(value, instID);
                }
                break;
            case 'dddate':
                //console.log(id);
                //console.log(value);
                if (currDate != value) {
                    setCurrDate(value, $(this).data("id"));
                }
                break;
        }


    } );

    $(document).on("click", ".btngraph", function () {

        if (currGraph != $(this).data("graph")) {
            currGraph = $(this).data("graph");
            getGraph();
        }
    });
    
});

function load_sidebar() {
    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/graph/graphs", function (data) {
        
    } ).done (function (data, json) {
        var html = "";
        
        var snippet1='<a class="list-group-item list-group-item-action btngraph';
        var snippet2='" id="list-graph-';
        var snippet3='-list" data-toggle="list" href="#list-graph-';
        var snippet4='" role="tab" aria-controls="graph-';
        var snippet5='" data-graph="';
        var snippet6='</a>';
        var first_line = true;
        graphs=data;

        $.each (data, function(key, val) {
            html += snippet1;
            if (first_line == true) {
                first_line = false;
                currGraph = key;
                html += ' active ';
            }
            html += snippet2 +  val["id"] + snippet3 +  val["id"] + snippet4 + val["id"] + snippet5 + key + '">' + val["graph_name"] + snippet6;
        }) ;

        $("#list-tab").html(html);
    } ).fail (function ( jqxhdr, textStatus, error) {
        console.log(textStatus, error, jqxhdr);
    });
}

function populateClients() {

    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/client/clients", function (data) {
        
    } ).done (function (data, json) {
        html = "";
        
        $.each (data, function(key, val) {
            html += '<a class="dropdown-item dditem" href="#">' + val["client_name"]  + '</a>';
        }) ;

        $("#ddclient").html(html);    
        setCurrClient(data[0]["client_name"]);
        
    } ).fail (function ( jqxhdr, textStatus, error) {
        console.log(textStatus, error, jqxhdr);
    });
}

function setCurrClient(client) {

    currClient = client;
    
    $("#btnclient").text("Client : " + currClient + " ");

    populateHost();
}

function populateHost() {

    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/host/hosts/"+currClient, function (data) {
        
    } ).done (function (data, json) {
        html = "";
        
        $.each (data, function(key, val) {
            html += '<a class="dropdown-item dditem" href="#">' + val["host_name"]  + '</a>';
        }) ;

        $("#ddhost").html(html);
        
        setCurrHost(data[0]["host_name"]);

    } ).fail (function ( jqxhdr, textStatus, error) {
        console.log(textStatus, error, jqxhdr);
    });
}

function setCurrHost(host) {

    currHost = host;
    $("#btnhost").text("Host : " + host + " ");
    populateInstance();

}

function populateInstance() {

    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/instance/instances/", {'host':currHost, 'client':currClient})
    .done (function (data, json) {
        html = "";
        
       
        $.each (data, function(key, val) {

            html += '<a class="dropdown-item dditem" href="#" data-id="' + val["id"] + '">' + val["instance_name"]  + '</a>';
        }) ;
        //console.log(html);
        $("#ddinstance").html(html);
        setCurrInstance(data[0]["instance_name"], data[0]["id"]);
        
    } ).fail (function ( jqxhdr, textStatus, error) {
        console.log(textStatus, error, jqxhdr);
    });
}

function setCurrInstance(instance, instanceID) {
    currInstance = instance;
    currInstanceID = instanceID;

    InstanceSet.resolve();

    $("#btninstance").text("Instance : " + currInstance + " ");
    populateDate();
}

function populateDate() {

    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/metric/dates/" + currInstanceID, function () {
        
    } ).done (function (data) {
        //console.log("data" + data); 
        html = "";          
        values=$.parseJSON(data);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         "";
        //console.log($.parseJSON(data));
        values.forEach(function(val) {
            html += '<a class="dropdown-item dditem" href="#" data-id="' + val + '">' + val  + '</a>';
        }) ;

        $("#dddate").html(html);

        setCurrDate(values[0]);
        
    } ).fail (function ( jqxhdr, textStatus, error) {
        console.log(textStatus, error, jqxhdr);
    });
}

function setCurrDate(date) {
    currDate = date;

    DateSet.resolve();
    $("#btndate").text("Date : " + currDate + " ");
    getGraph();
}

// to finnish - 
/*
function getMetrics(metrics, date) {

    var metricName = "";
    
    for (i in metrics) {
        if (metricName != "" ) metricName +="~";
        metricName += metrics[i].metric_name;
    }
    //console.log (metricName);
   
    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/metric/metrics/" + currFileID + "/" + metricName +"/"+ fileDate ).done (function (data) {
        displayGraph(metrics, $.parseJSON(data));
    } ).fail (function ( jqxhdr, textStatus, error) {
        console.log(textStatus, error, jqxhdr);
    }); 
}
*/
function getGraph() {
    
    $.when(InstanceSet, DateSet).done (function () {
        
        $.getJSON("http://localhost/analyseifx/webserver/index.php/api/series/series/" + graphs[currGraph]["id"] + "/" + currInstanceID + "/" + currDate)
        .done (function (data) {
            //currSeries = data;
            var returned = JSON.parse(data);
            //console.log(returned);
        
            //getMetrics(returned, currDate);
            displayGraph(returned);
            
        } ).fail (function ( jqxhdr, textStatus, error) {

            console.log(textStatus, error, jqxhdr);
            $("#legend").html("<h1>Under Construction</h1>");
        });
    }); 

}

function displayGraph(data) {
    var text = []; //["Date", "Disk Reads"];
    
    var baseval = [];
    var labels = ["Time"];
    var maxminset = false;
    var basetime = new Date(data[0].data[0].date);
    var graph_type = graphs[currGraph]["graph_type"];
    var isStacked = (graph_type == "STACKED"); 

   // console.log ("isStacked " + isStacked + " " + graph_type + " " + graphs[currGraph]["graph_type"]);

    var seriesCount = data.length;

    var title = graphs[currGraph]["graph_title"];
    var min = Number.MAX_VALUE;
    var max = -Number.MAX_VALUE;
    var i;
    
    //console.log(Number.MIN_VALUE);
    for ( i=0; i < seriesCount; i++) {

        if (data[i].data.length == 0) {
            seriesCount = i;
            break;
        }

        baseval[i] = +data[i].data[0].datum;
        //console.log("baseval " + baseval[i]);
        
        labels.push(data[i].series_label);
    }
    
    // iterate through the data rows
    for (var cnt=0;  cnt < data[0].data.length; cnt++) {

        var dataval = [];
        var items = [];
        var datetime = data[0].data[cnt].date;
        var rollperiod = 1;
        var dt = new Date(datetime);
        

        // load time as the first data input for the graph
        items.push(dt);

        timediff = +dt - basetime;
        basetime = +dt;
        var pushdata=true;

        // iterate through the data columns
        for (i=0; i < seriesCount; i++) {
                
            var value = data[i].data[cnt].datum;
            rollperiod = data[i].average;

            if (data[i].series_type == "difference") {
                dataval[i] = +value - baseval[i];

                if (dataval[i] < 0 ) {
                    pushdata=false;
                }
                
                baseval[i] = +value;
            } else {
                if (data[i].series_type == "time diff" ){   
                    dataval[i] = (+value - baseval[i]) / timediff;
                    baseval[i] = +value;
                    
                    if (dataval[i] < 0 ) {
                        pushdata=false;
                    }

                } else {
                    dataval[i] = +value;
                }
            }
            
            if (! isNaN(dataval[i])) {
                
                if (dataval[i] > max) {
                    max = dataval[i];
                    //console.log(dataval[i] + " max is now " + max);
                }
                if (dataval[i] < min) {
                    min = dataval[i];
                    //console.log(dataval[i] + " min is now " + min);
                }
            } else {
                console.log ("NAN");
            }
            items.push(dataval[i]);
            //console.log(items);   
        } // end of the iteration across the columns
        
        if (pushdata == true) text.push(items);
    
    } // end of the iteration across the rows
    
    if (max == min) {
        max += 10;
        min -= 10;
    }

    max = max * 1.05;
    min = min * 0.95;

    //console.log("max " + max + " min " + min);

    g = new Dygraph(

        // containing div
        document.getElementById("graph"),
    
        // CSV or path to a CSV file.
        text,
        {
            labels: labels,
            valueRange:[min, max],
            xlabel:'Time',
            legend: 'always',
            title: title,
            hideOverlayOnMouseOut: true,
            showRangeSelector: true,
            labelsDiv: 'legend',
            rollPeriod: rollperiod,
            showRoller: true,
            stackedGraph: isStacked,
            axes: {
                x: {
                    valueFormatter: function(ms) {
                        return formatDate(new Date(ms));
                    }
                }
            }
        }
    );

}

function formatDate(d) {
    var h = d.getHours();
    var m = d.getMinutes();

    return (h < 10 ? '0' : '') + h + ":" + (m < 10 ? '0' : '') + m;
}
