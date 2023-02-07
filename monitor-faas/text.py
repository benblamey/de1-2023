html = """<!DOCTYPE html><html>
<head>
<meta http-equiv="Content-type" content="text/html; charset=utf-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/><link rel="stylesheet" href="/static/bootstrap.min.css" type="text/css"/><link rel="stylesheet" href="/static/vis-timeline-graph2d.min.css" type="text/css"/><link rel="stylesheet" href="/static/webui.css" type="text/css"/><link rel="stylesheet" href="/static/timeline-view.css" type="text/css"/><script src="/static/sorttable.js"></script><script src="/static/jquery-3.5.1.min.js"></script><script src="/static/vis-timeline-graph2d.min.js"></script><script src="/static/bootstrap.bundle.min.js"></script><script src="/static/initialize-tooltips.js"></script><script src="/static/table.js"></script><script src="/static/timeline-view.js"></script><script src="/static/log-view.js"></script><script src="/static/webui.js"></script><script>setUIRoot('')</script>

<link rel="shortcut icon" href="/static/spark-logo-77x50px-hd.png"></link>
<title>Spark Master at spark://spark-master:7077</title>
</head>
<body>
<div class="container-fluid">
<div class="row">
<div class="col-12">
<h3 style="vertical-align: middle; display: inline-block;">
<a style="text-decoration: none" href="/">
<img src="/static/spark-logo-77x50px-hd.png"/>
<span class="version" style="margin-right: 15px;">3.2.3</span>
</a>
Spark Master at spark://spark-master:7077
</h3>
</div>
</div>
<div class="row">
<div class="col-12">
<div class="row">
<div class="col-12">
<ul class="list-unstyled">
<li><strong>URL:</strong> spark://spark-master:7077</li>

<li><strong>Alive Workers:</strong> 1</li>
<li><strong>Cores in use:</strong> 4 Total,
0 Used</li>
<li><strong>Memory in use:</strong>
6.8 GiB Total,
0.0 B Used</li>
<li><strong>Resources in use:</strong>
</li>
<li><strong>Applications:</strong>
0 <a href="#running-app">Running</a>,
1 <a href="#completed-app">Completed</a> </li>
<li><strong>Drivers:</strong>
0 Running,
0 Completed </li>
<li><strong>Status:</strong> ALIVE</li>
</ul>
</div>
</div><div class="row">
<div class="col-12">
<span class="collapse-aggregated-workers collapse-table" onClick="collapseTable('collapse-aggregated-workers','aggregated-workers')">
<h4>
<span class="collapse-table-arrow arrow-open"></span>
<a>Workers (1)</a>
</h4>
</span>
<div class="aggregated-workers collapsible-table">
<table class="table table-bordered table-sm table-striped sortable">
<thead><th width="" class="">Worker Id</th><th width="" class="">Address</th><th width="" class="">State</th><th width="" class="">Cores</th><th width="" class="">Memory</th><th width="" class="">Resources</th></thead>
<tbody>
<tr>
<td>
<a href="http://192.168.2.147:8081">
worker-20230127121131-192.168.2.147-35341
</a>
</td>
<td>192.168.2.147:35341</td>
<td>ALIVE</td>
<td>4 (0 Used)</td>
<td sorttable_customkey="6925.0">
6.8 GiB
(0.0 B Used)
</td>
<td></td>
</tr>
</tbody>
</table>
</div>
</div>
</div><div class="row">
<div class="col-12">
<span id="running-app" class="collapse-aggregated-activeApps collapse-table" onClick="collapseTable('collapse-aggregated-activeApps','aggregated-activeApps')">
<h4>
<span class="collapse-table-arrow arrow-open"></span>
<a>Running Applications (0)</a>
</h4>
</span>
<div class="aggregated-activeApps collapsible-table">
<table class="table table-bordered table-sm table-striped sortable">
<thead><th width="" class="">Application ID</th><th width="" class="">Name</th><th width="" class="">Cores</th><th width="" class="">Memory per Executor</th><th width="" class="">Resources Per Executor</th><th width="" class="">Submitted Time</th><th width="" class="">User</th><th width="" class="">State</th><th width="" class="">Duration</th></thead>
<tbody>

</tbody>
</table>
</div>
</div>
</div><div>

</div><div class="row">
<div class="col-12">
<span id="completed-app" class="collapse-aggregated-completedApps collapse-table" onClick="collapseTable('collapse-aggregated-completedApps',
'aggregated-completedApps')">
                           <h4>
                           <span class="collapse-table-arrow arrow-open"></span>
<a>Completed Applications (1)</a>
</h4>
</span>
<div class="aggregated-completedApps collapsible-table">
<table class="table table-bordered table-sm table-striped sortable">
<thead><th width="" class="">Application ID</th><th width="" class="">Name</th><th width="" class="">Cores</th><th width="" class="">Memory per Executor</th><th width="" class="">Resources Per Executor</th><th width="" class="">Submitted Time</th><th width="" class="">User</th><th width="" class="">State</th><th width="" class="">Duration</th></thead>
<tbody>
<tr>
<td>
<a href="app/?appId=app-20230127121916-0000">app-20230127121916-0000</a>

</td>
<td>
blameyben_lecture1_array_example
</td>
<td>
4
</td>
<td sorttable_customkey="1024">
1024.0 MiB
</td>
<td>

</td>
<td>2023/01/27 12:19:16</td>
<td>ubuntu</td>
<td>FINISHED</td>
<td sorttable_customkey="1172051">
20 min
</td>
</tr>
</tbody>
</table>
</div>
</div>
</div><div>

</div>
</div>
</div>
</div>
</body>
</html>"""


import re

print("alive workers: "+re.search("<li><strong>Alive Workers:</strong> ([0-9]+)</li>", html).group(1))

result = re.search("<li><strong>Cores in use:</strong> (.+) Total,\s(.+) Used</li>\s<li><strong>Memory in use:</strong>\s(.+) Total,\s(.+) Used</li>",
          html).group(0).re

print("cores in use".group(0))
