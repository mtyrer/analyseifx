var currClient="none";
var currHost="none";
var currInstance="none";
var currInstanceID=0;
var InstanceSet=$.Deferred();
var FileDateSet=$.Deferred();
var currFileDate="none";
var currGraph="";
var graphs;
var currSeries;


$(document).ready(function () {
    // Step one - populate the drop downs with the first available client, host and instance
    
    // get - clients
    load_sidebar();

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
            case 'ddfiledate':
                console.log(id);
                console.log(value);
                if (currFileDate != value) {
                    setCurrFileDate(value);
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

    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/instance/instances/" + currHost, function (data) {
        
    } ).done (function (data, json) {
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
    populateFileDate();
}

function populateFileDate() {

    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/file/files/" + currInstanceID, function (data) {
        
    } ).done (function (data) {
        html = "";                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   "";
        
        //console.log("date: " + data[0]["filedate"]);    
        $.each (data, function(key, val) {
            html += '<a class="dropdown-item dditem" href="#">' + val["filedate"]  + '</a>';
        }) ;

        $("#ddfiledate").html(html);

        setCurrFileDate(data[0]["filedate"]);
        
    } ).fail (function ( jqxhdr, textStatus, error) {
        console.log(textStatus, error, jqxhdr);
    });
}

function setCurrFileDate(filedate) {
    console.log ("setCurrFileDate: " + filedate);
    currFileDate = filedate;

    FileDateSet.resolve();
    $("#btnfiledate").text("File date : " + currFileDate + " ");
    getGraph();
}

// to finnish - 
function getMetrics(metrics, fileDate) {

    var metricName = "";
    
    for (i in metrics) {
        if (metricName != "" ) metricName +="~";
        metricName += metrics[i].metric_name;
    }
    //console.log (metricName);
   
    $.getJSON("http://localhost/analyseifx/webserver/index.php/api/metric/metrics/" + currInstanceID + "/" + metricName +"/"+ fileDate ).done (function (data) {
        displayGraph(metrics, $.parseJSON(data));
    } ).fail (function ( jqxhdr, textStatus, error) {
        console.log(textStatus, error, jqxhdr);
    }); 
}

function getGraph() {
    
    $.when(InstanceSet, FileDateSet).done (function () {
        
        $.getJSON("http://localhost/analyseifx/webserver/index.php/api/series/series/" + graphs[currGraph]["id"] )
        .done (function (data) {
            currSeries = data;
            returned = JSON.parse(data);
            //console.log(returned);
        
            getMetrics(returned, currFileDate);
            
        } ).fail (function ( jqxhdr, textStatus, error) {
            console.log(textStatus, error, jqxhdr);
        });
    }); 

}

function displayGraph(metrics, data) {
    var text = []; //["Date", "Disk Reads"];
    
    var baseval = [];
    var labels = ["Time"];

    var seriesCount = metrics.length
    //console.log (seriesCount);

    var title = graphs[currGraph]["graph_title"];
    var min;
    var max;
    
    for (var i=0; i < seriesCount; i++) {
        baseval[i] = +data[0][metrics[i].metric_name];
        basetime = +data[0]["metric_date"];
        min = +data[1][metrics[i].metric_name] - data[0][metrics[i].metric_name];
        max = +data[1][metrics[i].metric_name] - data[0][metrics[i].metric_name];
        labels.push(metrics[i].label);
    }
    
    $.each (data, function(key, val) {
    
        var dataval = [];
        
        var items = [];
        time = new Date(val["metric_date"]);
        items.push(time);
        timediff = val["metric_date"] - basetime;
        basetime = +val["metric_date"];

        for (var i=0; i < seriesCount; i++) {
            
            if (metrics[i].series_type_name == "difference") {
                dataval[i] = +val[metrics[i].metric_name] - baseval[i];
                baseval[i] = +val[metrics[i].metric_name];
            } else {
                if (metrics[i].series_type_name == "time diff" ){            
                    dataval[i] = (+val[metrics[i].metric_name] - baseval[i]) / timediff;
                    baseval[i] = +val[metrics[i].metric_name];
                } else {
                        dataval[i] = +val[metrics[i].metric_name]
                }
            }

            if (dataval[i] > max) max = dataval[i];
            if (dataval[i] < min) min = dataval[i];
            items.push(dataval[i]);
            
        }
        
        text.push(items);
    
    });

    max = max * 1.05;
    min = min * 0.95;

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

//*/