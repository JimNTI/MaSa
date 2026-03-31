# TCP Server Skeleton

Detta är ett minimalt TCP-server skelett som lyssnar efter HTTP-requests och skickar tillbaka HTTP-responses. 

Filen utgör grunden för att bygga ett Sinatra-liknande webbramverk.

## 1. Kör Servern

**Starta servern:**
```bash
ruby tcp_server.rb
```

**Testa servern:**

*Alternativ 1 - Med webbläsare:*
- Öppna en webbläsare och gå till `http://localhost:4567/`
- Du bör se "Hello, World!" i webbläsaren
- I terminalen ser du den HTTP-request som webbläsaren skickade

*Alternativ 2 - Med request-filerna från example_requests:*

Du kan även testa med de faktiska HTTP-request filerna! Skapa en fil `send_request.rb`:
```ruby
require 'socket'

socket = TCPSocket.new('localhost', 4567)
socket.print File.read('../example_requests/get-index.request.txt')
socket.close_write
puts socket.read
socket.close
```

Kör sedan: `ruby send_request.rb`

Detta skickar en rå HTTP-request från era testfiler till servern och visar svaret!

**Stoppa servern:**
- Tryck `Ctrl+C` i terminalen

## 2. Kodförklaring

### TCPServer och Socket-programmering

#### Vad är TCPServer?

```ruby
server = TCPServer.new(@port)
```

`TCPServer` är en inbyggd klass (som följer med Ruby) som skapar en server som lyssnar på en specifik port (i vårt fall `4567`). En **port** är som en dörr på datorn där program kan ta emot anslutningar. 

En uppkoppling från en klients till en webbserver behöver en address (i vårt fall `localhost`) och en port. Om man inte anger vilken port en webbläsare ska koppla upp sig mot kör den som standard port 80.

När servern "lyssnar" betyder det att den väntar på att klienter (t.ex. webbläsare) ska ansluta.

#### Vad är en "session"?

En **session** är en anslutning från en klient. När någon öppnar `http://localhost:4567/` i sin webbläsare skapar webbläsaren en anslutning till servern. Denna anslutning kallas en session.

#### Blockerande operationer

```ruby
session = server.accept
```

`server.accept` är en **blockerande** operation. Det betyder att koden stannar här och väntar tills en klient ansluter. När en klient ansluter returnerar metoden ett session-objekt och koden fortsätter. 

Man kan tänka sig att det fungerar ungefär som när du tidigare skrivit `name = gets.chomp` någonstans i din kod.

### Tilldelning i While-statement

Detta är en Ruby-syntax som du kanske inte sett tidigare.

#### Pattern 1: Acceptera klienter i en loop

***Med* assignment-in-while:**

```ruby
while session = server.accept
  # kod här körs för varje klient som ansluter
end
```

***Utan* assignment-in-while (traditionell while-loop):**

```ruby
session = server.accept
while session
  # kod här körs för varje klient som ansluter
  session = server.accept  # hämta nästa klient
end
```

**Vad händer här?**

1. I den första varianten är det en **tilldelning INUTI while-villkoret**
2. `server.accept` väntar på en klient och returnerar ett session-objekt
3. Session-objektet **tilldelas** till variabeln `session`
4. Loopen fortsätter så länge `server.accept` returnerar något (vilket den alltid gör)
5. **Resultat**: Servern hanterar en request i taget, i all oändlighet

Fördelen med assignment-in-while är att man slipper upprepa `session = server.accept` två gånger (en gång innan loopen, en gång i slutet av loopen).

#### Pattern 2: Läsa rader från klienten

***Med* assignment-in-while:**

```ruby
while line = session.gets and line !~ /^\s*$/
  data += line
end
```

***Utan* assignment-in-while (traditionell while-loop):**

```ruby
line = session.gets
while line && line !~ /^\s*$/
  data += line
  line = session.gets  # läs nästa rad
end
```

**Vad händer här?**

1. `session.gets` läser **en rad i taget** från klienten
2. Raden **tilldelas** till variabeln `line`
3. Loopen fortsätter så länge:
   - `session.gets` returnerar något (inte `nil`), **OCH**
   - Raden INTE matchar regex `/^\s*$/` (tom rad med bara whitespace)
4. I HTTP-protokollet betyder en tom rad att headers är slut
5. **Resultat**: Vi läser alla rader tills vi hittar den tomma raden som separerar headers från body

Fördelen med assignment-in-while är återigen att man slipper upprepa `line = session.gets` två gånger.

**Varför stannar loopen vid tom rad?**

HTTP-requests har följande format:
```
GET / HTTP/1.1\r\n
Host: localhost:4567\r\n
\r\n              <-- Tom rad = headers slut
```

När vi stöter på den tomma raden (`\r\n`) matchar den regex `/^\s*$/` och loopen avbryts.

### HTTP Response Structure

När servern har läst requesten måste den skicka tillbaka ett svar (response). Ett HTTP-svar har en specifik struktur:

Läs mer om HTTP-responses: [HTTP Messages - Responses på MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/Messages#http_responses)

```ruby
session.print "HTTP/1.1 200\r\n"              # Statusrad
session.print "Content-Type: text/html\r\n"   # Header
session.print "\r\n"                          # Tom rad
session.print html                            # Body
```

#### Delarna i ett HTTP-svar:

1. **Statusrad** (`HTTP/1.1 200`):
   - Protokollversion (`HTTP/1.1`)
   - Statuskod (`200` betyder "OK")

2. **Headers** (`Content-Type: text/html`):
   - Metadata om svaret
   - Varje header är på formatet `Namn: Värde`

3. **Tom rad** (`\r\n`):
   - Separerar headers från body
   - **Viktigt**: Måste vara där!

4. **Body** (själva innehållet):
   - HTML, JSON, text, etc.

#### Varför `\r\n`?

HTTP-specifikationen kräver **CRLF** (Carriage Return + Line Feed) för radbrytningar, inte bara `\n` (Line Feed).

- `\r` = Carriage Return (CR)
- `\n` = Line Feed (LF)
- `\r\n` = CRLF (båda tillsammans)

Detta är samma som du såg i HTTP-request filerna från förra uppgiften!

## 3. Integrera din Request-klass

Nu när du förstår hur servern fungerar är det dags att integrera din `Request`-klass från HTTP-parser uppgiften.

### Förberedelse

1. Kopiera din `lib/request.rb` från HTTP-parser uppgiften
2. Placera den i rätt katalogstruktur (t.ex. `lib/request.rb` relativt till `tcp_server.rb`)

### Integrationssteg

#### Steg 1: Lägg till require

Högst upp i `tcp_server.rb`, efter `require 'socket'`, lägg till:

```ruby
require 'socket'
require_relative 'lib/request'  # Justera sökvägen om nödvändigt
```

#### Steg 2: Använd Request-klassen

Hitta kommentaren `#request = Request.new(data)` i koden och ta bort `#` så koden använder **din** Request-klass.

```ruby
request = Request.new(data)
```

#### Steg 3: Testa att parsingen fungerar

Lägg till utskrifter för att verifiera att din Request-klass fungerar:

```ruby
request = Request.new(data)

p request
```

### Verifiering

När du startar servern och besöker `http://localhost:4567/test?foo=bar` bör du se något liknande i terminalen:

```
RECEIVED REQUEST
----------------------------------------
GET /test?foo=bar HTTP/1.1
Host: localhost:4567
...
----------------------------------------
#<Request:0x00007f9a8b8c3d40 @method="GET", @resource="/test?foo=bar", @version="HTTP/1.1", @headers={"Host"=>"localhost:4567", ...}, @params={"foo"=>"bar"}>
```

**Grattis!** Din Request-klass fungerar nu med riktiga HTTP-requests, inte bara testfiler!

## Vad Saknas?

Testa servern genom att besöka olika URLs:
- `http://localhost:4567/`
- `http://localhost:4567/about`
- `http://localhost:4567/admin/users`

Du kommer märka att servern **alltid returnerar exakt samma svar**, oavsett vilken URL du besöker.

### Aktuella Begränsningar

**1. Ingen URL-hantering**

Servern läser requesten (inklusive vilken URL som begärts) men ignorerar denna information helt. Alla requests får samma innehåll i sitt svar.

**2. Hårdkodad respons**

Responsen byggs med hårdkodade strängar direkt i server-loopen:
```ruby
session.print "HTTP/1.1 200\r\n"
session.print "Content-Type: text/html\r\n"
session.print "\r\n"
session.print html
```

**3. Ingen separation**

All logik (läsa request, bestämma vad som ska hända, bygga response, skicka response) finns i samma metod.

### Frågor att Fundera På

- Hur skulle du vilja kunna definiera olika beteenden för olika URLs?
- Hur hanterar Sinatra att olika URLs gör olika saker?
- Vad händer om du vill returnera en bild istället för HTML för vissa URLs?
- Hur skulle du organisera koden för att enkelt kunna lägga till nya endpoints?

### Om Testning

Precis som i Phase 1 (HTTP-parser) är **TDD starkt rekommenderat** för den kod du skriver. Att kunna visa upp en testdriven utvecklingsprocess och välskrivna tester är ett tecken på högre kunskapsnivå.

Fundera på:
- Vilka delar av din lösning kan testas isolerat?
- Hur kan du testa utan att behöva starta hela servern?
- Vilka edge cases bör du hantera?
