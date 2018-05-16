import io.ktor.application.*
import io.ktor.features.ContentNegotiation
import io.ktor.gson.gson
import io.ktor.http.*
import io.ktor.request.receive
import io.ktor.response.*
import io.ktor.routing.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import java.text.DateFormat


fun main(args: Array<String>) {
    val server = embeddedServer(Netty, port = 8080) {
        install(ContentNegotiation){
            gson {
                setDateFormat(DateFormat.LONG)
                setPrettyPrinting()
            }
        }
        routing {

            get("/") {
                call.respondText("Hello World!", ContentType.Text.Plain)
            }

            post("/sentiment"){
                val sentence = call.receive<SentenceEntity>()
//
//                post("http://0.0.0.0:5050/analyse/sentiment") {
//
//                }
            }
        }
    }
    server.start(wait = true)
}