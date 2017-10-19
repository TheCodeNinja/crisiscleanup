import CCMap from '.'

var GoogleMapsApiLoader = require('google-maps-api-loader');

$(document).ready(function () {
  // try {
  var path = $(location).attr('pathname');
  var pathArray = path.split('/');
  var page = pathArray[2];
  var worker_map = $('#worker-map-canvas').length
  var event_id;

  // if a map is on the page get incident id
  if (worker_map !== 0) {
    event_id = typeof $('.m-id.hidden')[0] !== 'undefined' ? $('.m-id.hidden')[0].innerHTML : 'none';

    GoogleMapsApiLoader({
      libraries: ['places'],
      apiKey: process.env.GOOGLE_MAPS_API_KEY
    })
      .then(function (googleApi) {
        var site_id = parseInt($('#site-id').html());
        var ccmap = new CCMap.Map({
          elm: 'worker-map-canvas',
          event_id: event_id,
          site_id: site_id,
          public_map: false,
          form_map: pathArray.indexOf('form') !== -1,
          google: googleApi
        });
        // TODO: remove this once the worker map instantiation is setting the event correctly.
        ccmap.setEventId(event_id);
      }, function (err) {
        console.error(err);
      });
  }

  var csvDownloadBtnText = "CSV";
  if (!event_id || event_id === 'undefined') {
    event_id = $('#incident-chooser').find(":selected").val();
    csvDownloadBtnText = "Download CSV"
  }

  // Setup the download-csv-button if it's present
  var $dlbtn = $('#download-csv-btn');
  if ($dlbtn) {
    var jobId;

    function requestCsv() {
      $.ajax({
        type: "GET",
        url: "/worker/incident/" + event_id + "/download-sites.json?job_id=" + jobId,
        success: function (response, status, xhr) {
          if (response.status == 200 && response.hasOwnProperty('url')) {
            window.location.replace(response.url);
            enabled = true;
            $dlbtn.html(csvDownloadBtnText);
          } else if (response.hasOwnProperty('message')) {
            setTimeout(requestCsv, 5000);
          } else {
            setTimeout(requestCsv, 5000);
          }
        }
      });
    }

    var enabled = true;
    $dlbtn.click(function (e) {
      e.preventDefault();
      if (enabled) {
        enabled = false;
        $dlbtn.html('<span>Generating CSV, please wait . . . </span><i class="fa fa-spinner fa-spin"></i>');

        $.get("/worker/incident/" + event_id + "/download-sites", function (data) {
          jobId = data.job_id;
          requestCsv();
        });

      }
    });
  }
  // } catch (e) {
  //   Raven.captureException(e);
  // }
});
