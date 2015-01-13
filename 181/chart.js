
// set up data -----------------------------------------------------------------

function plot() {

  var rawinput = document.getElementById("input")
                         .value


  var lines = rawinput.split("\n");

  var limitmatches = lines[0].match(/is ([\d\.]+) (mph|km\/h)/)
  , limitunits = limitmatches[2]
  , converter =  (limitunits == "mph") ? 0.44704 : 0.277778
  , meters_per_s = limitmatches[1] * converter;

  var speedcameras = [];
  
  lines = lines.slice(1);
  var finished = false;

  while(!finished) {
    if(lines.length === 0) break;
    var l = lines[0]
    var m = l.match(/number (\d+) is (\d+)/)
    if(m) {
      speedcameras.push({camera: m[1], distance: +m[2]})
      lines = lines.slice(1)
    } else {
      finished = true;
    }
  }

  var maxDistance = d3.max(speedcameras, function(c){return c.distance});

  var vehicles = {};
  var currentCam;
  var minTime = Infinity;
  var maxTime = 0;
  var sHeight = 10;

  var cols = d3.scale.category20();

  lines.forEach(function(l){
    var infomatch = l.match(/Start of log for camera (\d+)\./);
    var logmatch = l.match(/Vehicle ([A-Z,0-9,\s]+) passed camera \d+ at ([0-9,:]+)/);
    if(infomatch){
      currentCam = +infomatch[1]
    } else if (logmatch) {
      var vehicle = logmatch[1]
      var timecode = logmatch[2].split(":")
      var time = new Date()
      time.setHours(timecode[0]);
      time.setMinutes(timecode[1]);
      time.setSeconds(timecode[2]);
      if (time < minTime) {
        minTime = time;
      }
      if (time > maxTime) {
        maxTime = time;
      }

      var vobj = {cam: currentCam, time: time, col: cols(vehicle)};

      if(vehicles[vehicle]) {
        vehicles[vehicle].push(vobj)
      } else {
        vehicles[vehicle] = [vobj];
      }
    }
  });

  vehicles = d3.map(vehicles).entries();

  function attachSpeeds(v){
    v.speeds = v.value.slice(1).reduce(function(acc,d){
      var delta_d = speedcameras[d.cam-1].distance - speedcameras[acc.last.cam-1].distance;
      var delta_t = (d.time - acc.last.time) / 1000;
      var speed = delta_d/delta_t;
      acc.speeds.push(speed);
      acc.last = d;
      return acc;
    }, {vn: v.key, speeds: [], last: v.value[0]}).speeds;
    return v;
  }

  vehicles = vehicles.map(attachSpeeds);

  // set up axes ----------------------------------------------------------------

  var y = d3.time.scale()
            .domain([minTime, maxTime]);

  var height = y.ticks(d3.time.seconds).length * sHeight;

  y.rangeRound([0,height]);

  var yAxis = d3.svg.axis()
                .scale(y)
                .orient("left")
                .ticks(d3.time.seconds, 2)
                .tickFormat(d3.time.format('%H:%m:%S'))

  var x = d3.scale.linear()
            .domain([0, maxDistance])
            .range([0,400]);

  var xAxis = d3.svg.axis()
                .scale(x)
                .orient("top")
                .ticks(10)

  // set up svg ------------------------------------------------------------------


  var margin = {top: 20, right: 10, bottom: 20, left: 80};

  var width = 960,
      height;

  var svg = d3.select("#grid").html("").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  // draw ------------------------------------------------------------------------

  svg.append('g')
    .attr('class', 'y axis')
    .call(yAxis);

  svg.append('g')
    .attr('class', 'x axis')
    .call(xAxis);

  var cameras = svg.selectAll(".camera")
    .data(speedcameras).enter()
        .append("g")
        .attr("class", "camera")
        .attr("transform",function(d){
            return "translate(" + x(d.distance) + ", 0)";
        })

  cameras.append("line")
      .attr("x1", 0)
      .attr("x2", 0)
      .attr("y1", 0)
      .attr("y2", height)
      .attr("class", "cameraline")
      .attr("stroke-dasharray", "2, 4")

  cameras.append("text")
      .attr("x", 0)
      .attr("y", height + 20)
      .attr("text-anchor", "middle")
      .text(function(d){return "Cam " + d.camera + " (" + d.distance + "m)"}) 
      .attr("font-size", "12px")
      .attr("font-family", "sans-serif")

  var vehicleGroup = svg.selectAll(".vehicle")
                        .data(vehicles)
                        .enter()
                        .append("g")
                        .attr("class", "vehicle")
                        .attr("data-vehicle", function(d){return d.key})

  var lineFunction = d3.svg.line()
                      .x(function(d){return x(speedcameras[d.cam - 1].distance)})
                      .y(function(d){return y(d.time)})
                      .interpolate("linear")

  vehicleGroup.selectAll("path").data(function(d){return [d.value]})
                .enter().append("path")
                  .attr("d", lineFunction)
                  .attr("stroke", function(d){return d[0].col})
                  .attr("fill", "none")

  vehicleGroup.selectAll(".point").data(function(d){return d.value})
              .enter()
                .append("circle")
                  .attr("r", 4)
                  .attr("cx", function(d){return x(speedcameras[d.cam - 1].distance)})
                  .attr("cy", function(d){return y(d.time)})
                  .attr("fill", function(d){return d.col})
                  .attr("class", "point")

  var table = svg.append("g").attr("class", "vehicle-table")
                .attr("transform", "translate(560,40)")
                .attr("font-size", "12px")
                .attr("font-family", "sans-serif")

  table.append("text")
       .text("Vehicle")
       .attr("font-weight", "bold")
       .attr("text-anchor", "end")
       .attr("x", -40)
       .attr("y", -30);

  table.append("line")
    .attr("x1", -100)
    .attr("x2", ((speedcameras.length -1) * 80) - 20)
    .attr("y1", -20)
    .attr("y2", -20)


  table.append("line")
    .attr("x1", -30)
    .attr("x2", -30)
    .attr("y1", -20)
    .attr("y2", vehicles.length * 28)
    .attr("stroke-dasharray", "1,3")

  for(i = 1; i < speedcameras.length; i++) {
    table.append("text")
         .text("Cam" + (i) + "-" + (i+1))
         .attr("text-anchor", "end")
         .attr("x",  28 +((i-1) * 80))
         .attr("y", -30)
  }

  var rows = table.selectAll(".row").data(vehicles).enter()
                  .append("g")
                    .attr("data-vehicle", function(d){return d.key})
                    .attr("transform", function(_, i){return "translate(0," + i * 30 + ")"})
                    .on("mouseover", function(d){
                      d3.selectAll(".vehicle")
                        .attr("opacity", 0.2)

                      d3.selectAll(".vehicle")
                        .filter(function(v){
                          return d.key == v.key
                        })
                        .attr("opacity", 1)
                    }).on("mouseout", function(d){
                      d3.selectAll(".vehicle")
                        .attr("opacity", 1)
                    })
                    .attr("style", "cursor: pointer")

  rows.append("rect")
    .attr("x", -100)
    .attr("y", -10)
    .attr("fill", "transparent")
    .attr("height", 30)
    .attr("width", 500)

  rows.append("text").text(function(d){return d.key})
      .attr("font-weight", "bold")
      .attr("text-anchor", "end")
      .attr("dx", -40)
      .attr("fill", function(d){
        return cols(d.key)
      })

  rows.selectAll(".speed").data(function(d){return d.speeds})
    .enter()
      .append("text")
        .attr("x", function(_, i){return 40 +(i * 80)})
        .attr("text-anchor", "end")
        .text(function(d){return d3.format('05.2f')(d / converter) + limitunits})
        .attr("fill", function(d){
          if(d > meters_per_s) {
            return "#f00"
          } else {
            return "#444"
          }
        });
}

plot();

d3.select("#redraw").on("click", plot)
