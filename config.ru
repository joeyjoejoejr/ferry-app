require "./app"
require "./app/middlewares/event_websocket"

use FerryApp::EventWebsocket

run FerryApp::App
