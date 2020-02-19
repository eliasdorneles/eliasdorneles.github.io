Title: Programming Grails -- a aventura continua
Date: 2013-07-28 10:12
Author: Elias Dorneles
Slug: Programming-Grails----a-aventura-continua

Alguns dias atrás terminei de ler o *[Programming
Grails](http://shop.oreilly.com/product/0636920024750.do "Programming Grails - OReilly") ([Amazon](https://www.amazon.com/Programming-Grails-Burt-Beckwith/dp/1449323936))*,
um livro sobre [o framework Grails](http://www.grails.org/) voltado para
desenvolvedores experientes, que explica como funcionam várias coisas do
framework e aponta vários caminhos das pedras. O autor é [Burt
Beckwith](http://burtbeckwith.com/), conhecido na comunidade Grails por
criar vários plugins úteis do Grails, [escrever sobre Grails no seu
blog](http://burtbeckwith.com/blog/), [responder perguntas no
StackOverflow](http://stackoverflow.com/users/160313/burt-beckwith "Burt Beckwith no StackOverflow"),
[palestrar](http://www.infoq.com/author/Burt-Beckwith) em
[conferências](http://gr8conf.eu/Speakers/Burt-Beckwith) e
também colaborar no desenvolvimento do próprio Grails.

[![Programming Grails -- Best Practices for Experienced Grails Developers](https://eljunior.files.wordpress.com/2013/07/cat.gif)](http://shop.oreilly.com/product/0636920024750.do)

Comprei o livro na Amazon ainda antes do lançamento oficial porque sabia
que sendo material do Burt seria muito bom. Não me decepcionei: o livro
é excelente! Na mesma semana que comecei a ler já pude aplicar as idéias
do livro, e minha compreensão do framework melhorou bastante --
recomendo fortemente pra quem trabalha com o framework. O livro não é
para iniciantes, todavia -- para quem quer começar com Grails, pode ser
melhor pegar um livro como o [Grails in
Action](http://www.manning.com/gsmith2/) ou o [The Definitive Guide to
Grails 2](http://www.apress.com/java/java-ee/9781430243779).

### Introdução a Groovy

O texto começa com uma introdução à linguagem
[Groovy](http://groovy.codehaus.org/), a linguagem usada no
desenvolvimento com Grails, demonstrando várias particularidades da
linguagem e sua excelente interoperabilidade com Java, explicando alguns
detalhes da implementação e exemplificando as várias vantagens que a
linguagem oferece em relação a Java. Já estou usando Groovy há um bom
tempo, mas essa introdução esclareceu algumas coisas sobre a linguagem.



Um destaque dessa parte é a explicação sobre [*owner*, *delegate* e
*this* nas closures em
Groovy](http://groovy.codehaus.org/Closures "Groovy Closures -- documentação oficial").
Basicamente, numa closure em Groovy, ***this*** se refere à instância da
classe que contém a Closure, ***owner*** se refere ou a essa instância
ou a outra closure que esteja envolvendo a closure atual, e
***delegate*** é uma variável mutável que por padrão aponta pra owner. O
interessante aqui é que você pode alterar o valor de *delegate* em tempo
de execução, e redefinir todo o comportamento da closure. Essa técnica é
bastante utilizada para criar as [mini-linguagens
(DSLs)](https://pt.wikipedia.org/wiki/Linguagem_de_dom%C3%ADnio_espec%C3%ADfico)
em Grails, tipo as que você usa nos blocos *mapping* e *constraints*
numa classe de domínio.

Segue um exemplo pra ajudar a entender:

    :::groovy
    class OutraClasse {
        def metodoDaOutraClasse() {
            println "metodoDaOutraClasse()"
            }
        }
        class ClasseMae {
            def minhaClosure = {
                def subClosure = {
                    println "this: ${this.class}"
                    println "owner: ${owner.class}"
                    println "delegate: ${delegate.class}"
                    metodoDaOutraClasse()
                }
            subClosure.delegate = new OutraClasse()
            subClosure()
        }
    }
    new ClasseMae().minhaClosure()


Nesse exemplo, por causa da redefinição do delegate da *subClosure()*,
podemos chamar métodos da *OutraClasse* dentro dele. O resultado de
rodar esse código é:

    this: class ClasseMaeowner: class ClasseMae$_closure1delegate: class OutraClassemetodoDaOutraClasse()

Recomendo assistir a palestra [Functional Programming in
Groovy](http://gr8conf.eu/Presentations/Functional-Programming-in-Groo),
para ver um exemplo legal de uso do *delegate* simplificando uma API de
envio de email.

### Grails Internals

O livro avança falando do framework Grails, das várias escolhas que
foram feitas na sua criação e evolução, e explica como criar e rodar uma
aplicação, narrando o que acontece quando você roda cada comando. A
seguir, Burt descreve todos os plugins incluídos na instalação padrão:
para o que servem, como foram implementados e como você pode
configurá-los ou desativá-los, se assim desejar.

Este capítulo define o tom do livro, no
sentido de que ele é bem voltado para quem deseja saber melhor como as
coisas funcionam. Por isso, ele pode ser um tanto entediante para alguém
que esteja buscando algo mais receita-de-bolo garantindo gratificação
imediata -- o livro fala bastante nos detalhes de implementação de
várias partes do framework, com a idéia de habilitar você a resolver
problemas em todos os níveis de abstração envolvidos no desenvolvimento
de uma aplicação Grails.

Acho que esse é o tipo de livro que é bom ter sempre por perto quando
estiver desenvolvendo para poder consultar. Várias vezes desejei
consultá-lo quando estava no trabalho, lembrando ter lido algo que ia
ajudar no problema que estava resolvendo. Então, a dica é mantê-lo ao
alcance -- agora eu carrego na mochila. :)

Bem, seguindo adiante, o Burt fala de persistência com o
[GORM](http://grails.org/GORM) (Grails Object Relational Mapping),
passando dicas de configuração pra facilitar a vida na hora de depurar o
código -- configurar um método nas classes de domínio para mensagens de
erro mais amigáveis, um filtro pra converter brancos em nulos, entre
outros.


### Spring e Injeção de Dependência

O capítulo seguinte é sobre o papel do
[Spring](https://pt.wikipedia.org/wiki/Spring_Framework) e [injeção de
dependência](https://pt.wikipedia.org/wiki/Inje%C3%A7%C3%A3o_de_depend%C3%AAncia)
no Grails, explicando o funcionamento dos serviços Grails (que são beans
do Spring com suporte a transação), vários detalhes de configuração que
funcionam em cima do Spring, incluindo como integrar com outras
aplicações Spring já existentes. Aqui você já deve entender que é a
flexibilidade do Spring e a riqueza do ecossistema em torno dele que
garantem bastante poder ao Grails e a facilidade de integrar com várias
tecnologias diferentes. Acho que o Grails é um bom exemplo de tecnologia
que aproveita bastante as outras soluções já existentes no mercado por
isso.

Aliás, apesar de conter vários pontos excelentes, esse capítulo sobre Spring
foi uma leitura um tanto árida -- em alguns momentos o texto descreve detalhes
de implementação de maneira complicada de entender, coisas tipo: “pra fazer
`<algum recurso>`, Grails instancia a classe `<fully qualified name da classe
aqui>`, que implementa a interface `<outro fully qualified name aqui>` e usa o
adapter `<ainda outro fully qualified name>`, registrando um bean `<nome do
bean>` ...“!

Ficou um pouco difícil de acompanhar, especialmente por eu não estar na
frente da IDE, sem poder conferir facilmente as definições das classes.
Bem, eu sabia onde estava me metendo quando peguei um livro avançado,
acho que o Burt fez um excelente trabalho com o livro, mas houveram
esses trechos que reli várias vezes e continuei sem entender. Talvez meu
conhecimento de *design patterns* esteja fraco -- nunca fiz questão de
estudá-los muito, de qualquer forma.

### Hibernate


A seguir, vem o maior capítulo do livro, dissecando o uso do Hibernate com
Grails, tanto com e sem o GORM. Aqui ele explica vários detalhes de
funcionamento do mapeamento objeto-relacional e como usá-lo para obter o máximo
de benefício. Burt sugere brincar com uma aplicação configurada com Hibernate
puro (isto é, sem o plugin do Hibernate pro Grails & GORM) como um exercício
útil pra entender o que Grails provê de graça pra você.


Um trecho muito legal desse capítulo é a parte sobre *caching*, em que ele
mostra como configurar o mecanimo de cache do Grails (usando
[Ehcache](http://ehcache.org/)) e testar usando o console do Grails (*grails
console*), conferindo as saídas do log. Compreendi melhor como funciona o
esquema de cache do Grails e como tirar vantagem dele minimizando os riscos de
acontecer merda. Tem [uma apresentação do Burt relacionada a esse assunto
disponível online](http://www.infoq.com/presentations/GORM-Performance), vale
conferir.



Bem, ainda nesse capítulo (eu falei que era o maior do livro =P), vem
uma série de dicas sobre o uso do GORM com Hibernate, incluindo um
configurador de nomes para as chaves estrangeiras (porque os
        *FK1236718237* que o Hibernate gera por padrão são crípticos demais na
        hora de depurar), como mapear views e subclasses, diferenças entre
[get](http://grails.org/doc/latest/ref/Domain%20Classes/get.html)/[load](http://grails.org/doc/latest/ref/Domain%20Classes/load.html)/[read](http://grails.org/doc/latest/ref/Domain%20Classes/read.html)
e algumas dicas sobre performance. Sobre esse assunto, também recomendo
ler os posts do Peter Ledbrook da série GORM Gotchas, seguem os links:

1.  <http://blog.springsource.org/2010/06/23/gorm-gotchas-part-1/>
2.  <http://blog.springsource.org/2010/07/02/gorm-gotchas-part-2/>
3.  <http://blog.springsource.org/2010/07/28/gorm-gotchas-part-3/>

Especificamente sobre o comportamento do [método
save()](http://grails.org/doc/latest/ref/Domain%20Classes/save.html "save()")
explicado no primeiro post dessa série GORM Gotchas, eu [penso um pouco
diferente](https://eljunior.wordpress.com/2013/06/03/aventurando-se-com-grails/)
dos autores do framework e sempre configuro a chave
`grails.gorm.failOnError=true` no *Config.groovy* logo após criar um
projeto novo em Grails. Acho que é especialmente importante fazer isso
quando a equipe de desenvolvedores é um pouco heterogênea ou recém está
começando a usar o framework -- você evita muitas sessões de depuração
quando o *save()* sempre ou salva ou erra berrantemente.

### Integração



Em sequência tem um capítulo sobre integração, em que o livro cobre as
facilidades do Grails para usar mensageria com JMS, enviar emails de
forma assíncrona, criar e acessar WebServices SOAP usando os plugins
[CXF](http://grails.org/plugin/cxf) e [CXF
client](http://grails.org/plugin/cxf-client), criar e acessar
WebServices REST com os plugins [JAX-RS](http://grails.org/plugin/jaxrs)
e [REST Client Builder](http://grails.org/plugin/rest-client-builder) e
também como habilitar gerenciamento e monitoração com o [plugin
JMX](http://grails.org/plugin/jmx). Ah, outra coisa legal que o Burt
mostra nesse capítulo é como usar o [plugin
TCPMon](http://grails.org/plugin/tcpmon) para depurar as requisições que
chegam no servidor rodando em desenvolvimento -- ele funciona como um
*proxy* rodando em outra porta e tem uma interface desktop pra
inspecionar os dados da requisições, bem interessante.

### Configuração



Depois tem um capítulo dedicado ao assunto de configuração, que ensina uma
série de truques para organizar suas configurações. É bem útil, porque no
Grails as configurações podem ficar um pouco bagunçadas, então é legal dar uma
arrumada na casa de vez em quando. Como alguns arquivos suportam algumas
funcionalidades especiais, às vezes são necessários alguns truques pra
modularizá-los ou fazer as configurações específicas por ambiente.

### Plugins



Esse capítulo é bem legal, explica como funciona o mecanismo de plugins
do Grails e ensina as boas práticas na hora de criar seu próprio plugin.
Curti bastante o esquema de plugins do Grails, é realmente bem poderoso:
a estrutura de um plugin é bem parecida a de uma aplicação, podendo
adicionar classes de domínio, controllers, filtros, recursos estáticos
(Javascript, CSS), beans do Spring, e tudo o mais.



Isso quer dizer que é fácil de quebrar suas aplicações em vários
plugins, bastando você manter as relações de dependências adequadas
entre as classes -- e o livro tem uma seção dedicada a fazer justamente
isso, incluindo publicar os plugins num repositório local com o
[Artifactory](http://www.jfrog.org/).



Nesse mesmo capítulo, o Burt demonstra sua experiência no
desenvolvimento de vários plugins detalhando seu workflow para
desenvolver e testar vários plugins, usando diferentes versões do
framework -- muitas dicas úteis.

### Segurança



*“O propósito desse capítulo é assustar você.”* É assim que começa o capítulo
do Programming Grails sobre segurança -- que é excelente, por sinal! Aqui, Burt
explica vários riscos (os [Top Ten da
OWASP](https://www.owasp.org/index.php/Category:OWASP_Top_Ten_Project), o livro
usou os de 2010, mas já saiu uma lista atual) aos quais sua aplicação pode
estar vulnerável caso você não tome certos cuidados.


O livro dá várias dicas de como melhorar a segurança das aplicações, e
explica como usar alguns plugins interessantes que ajudam a melhorar
alguns aspectos de segurança. Como o assunto é complicado, vou apenas
dizer aqui alguns pontos muito importantes que todo mundo usando Grails
precisa ficar ligado:


**1)** Considere configurar o codec de HTML por padrão para as páginas
GSP, no *Config.groovy*:


    :::groovy
    grails.views.default.codec = 'html'


Dessa forma, as variáveis usadas nas páginas GSP serão escapadas com
HTML por padrão -- a configuração (*'none'*) não escapa nada, uma
escolha infeliz que tem sido mantida pra não quebrar compatibilidade.


**2)** Não implemente seu próprio mecanismo de autenticação e autorização. Use
os plugins/frameworks testados e aprovados pela comunidade (uso e recomendo o
[Spring Security](http://www.springsource.org/spring-security), cujo [plugin
pro Grails](http://grails.org/plugin/spring-security-core) foi feito por
ninguém menos que o próprio Burt Beckwith). Tem muitos tutoriais de Grails na
Internet ensinando a fazer autorização usando filtros, implicando que é fácil
de fazer autorização -- dica: não é! À medida que vai desenvolvendo a
aplicação, você descobre que precisa de vários outros recursos relacionados:
*hash* decente para as senhas, gerenciamento da sessão, fluxo para “esqueci a
senha”, etc. Se você implementar esses recursos você mesmo, aumenta bastante o
risco de acabar fazendo alguma coisa errada. Portanto, faça uso do que está
disponível, invista em estudar os plugins disponíveis -- vale a pena.


**3)** Capriche. Teste sua segurança com testes funcionais, não com testes
unitários ou de integração que usam mocks e stubs. Faça revisão de código com a
equipe para procurar vulnerabilidades em potencial.  Mantenha-se atualizado
sobre as atualizações do framework. Aprenda [a fazer data binding com
segurança](http://blog.springsource.org/2012/03/28/secure-data-binding-with-grails/).

### Cloud, AOP e Upgrade

O livro dedica um breve capítulo explicando o deploy no Cloud, falando das
vantagens/desvantagens, e explicando passo-a-passo como fazer deploy de
aplicações que usam banco de dados no [Cloud
Foundry](http://www.cloudfoundry.com/) e [Heroku](http://www.heroku.com/), e
algumas configurações para fazer escalar. Curti! =)

A seguir, vem um trecho interessante sobre as técnicas de [programação
orientada a
aspectos](https://pt.wikipedia.org/wiki/Programa%C3%A7%C3%A3o_orientada_a_aspecto)
disponíveis por padrão no Grails (basicamente, as mesmas já disponíveis no
Spring só que empoderadas pela linguagem Groovy), e também como adicionar
outras capacidades usando o [plugin AspectJ](http://grails.org/plugin/aspectj).
Burt ilustra AOP com uma maneira de avisar se algum método das classes de
domínio que altera o estado do banco está sendo chamado fora de um contexto de
transação -- *pretty cool stuff*!


Por fim, o último capítulo detalha os procedimentos para fazer upgrade de
aplicações para versões mais novas do Grails (Burt usa um método sofisticado
que inclui fazer um *diff* com uma aplicação nova criada com a mesma versão da
aplicação legada, pra saber com precisão o que foi alterado), e faz um breve
histórico das mudanças nas versões mais importantes do Grails, explicando as
novidades e rumos tomados no framework.


A maior mudança foi na versão 2.0, que trouxe vários plugins novos, adotou a
jQuery e muitas melhorias - e algumas quebras de compatibilidade. Algumas das
mudanças que causam quebra são: os métodos nos controllers também são
considerados como actions (antes eram apenas closures), os JOINs com Criteria
são INNER joins em vez de LEFT joins, alguns nomes dos recursos na configuração
dos logs mudaram e a inclusão do [plugin
resources](http://grails.org/plugin/resources) pode forçar algumas alterações.
Sempre vale conferir [a documentação oficial na hora de fazer o
upgrade](http://grails.org/doc/latest/guide/upgradingFromPreviousVersionsOfGrails.html).
O Peter Ledbrook também tem algumas [dicas para o upgrade para Grails
2](http://pledbrook.github.io/grails-howtos/en/upgradeToGrails2.html).

### Conclusão

Enfim, o livro é muito bom, recomendo fortemente pra quem esteja usando
Grails, descobri várias coisas novas e ainda quero botar em prática
várias idéias que aprendi nele. Como já disse no início, para quem quer
começar com Grails pode ser mais adequado usar outro material antes, mas
logo depois de pegar o jeito já pode partir para o *Programming Grails*
-- a satisfação é garantida.


*That’s all, folks! =)*

