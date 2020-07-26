#!/bin/bash

cp /gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/copied-run-files/loadprofile.scala /gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/user-files/simulations/
/gatling_run_dir/gatling-charts-highcharts-bundle-3.3.1/bin/gatling.sh -nr -s loadprofile > run.log