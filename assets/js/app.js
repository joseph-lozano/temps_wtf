// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"

import regression from 'regression'



import Chart from 'chart.js'
var ctx = document.getElementById('chart')
var myChart = new Chart(ctx, {
    type: 'line',
    data: {
        labels: [],
        datasets: [{
            label: 'Highest Recored Temperature per Year',
            data: [],
            fill: false,
            borderColor: "orange",
            cubicInterpolationMode: 'default'
        },
        { label: "Linear Regression", data: [], borderColor: "red", fill: false }]
    },
    options: {
    }
});

let Hooks = {}
Hooks.Chart = {
    mounted() {
        this.handleEvent("chart", ({ data }) => {
            var clean_data = data.labels.map((el, i) => {
                return [i, data.data[i]]
            })

            var regression_data = regression.linear(clean_data)
            myChart.config.data.datasets[0].data = data.data
            myChart.config.data.datasets[1].data = regression_data.points.map(([x, y]) => y)
            myChart.config.data.datasets[1].label = `Linear Regression: ${regression_data.string}`
            myChart.config.data.labels = data.labels
            myChart.update()
        })
    }
}
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

