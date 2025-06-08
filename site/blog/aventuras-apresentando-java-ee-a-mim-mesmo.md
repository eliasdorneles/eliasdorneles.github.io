Title: Aventuras apresentando Java EE a mim mesmo
Date: 2013-01-15 07:45
Author: Elias Dorneles

> **Cuidado:** o texto a seguir contém níveis perigosos de nerdice,
> acrônimos e javeiragem em geral.

Não sou nenhum fã de Java: a linguagem eu realmente **não** curto (não
tenho culpa de ter conhecido
[Python](http://www.python.org/ "Python.org") e
[Ruby](http://www.ruby-lang.org/ "Ruby-Lang.org") antes :P), todavia a
plataforma tem os seus apelos. Só que eu estava ficando com vergonha de
ainda desconhecer o *stack* do [Java
EE](https://en.wikipedia.org/wiki/Java_EE), ao passo que uso diariamente
várias tecnologias relacionadas no meu trabalho. Por isso, decidi que
iria tomar vergonha na cara e estudar um pouco mais da parada (e tentar
reclamar menos). Comprei [o
livro](http://antoniogoncalves.org/2009/02/13/java-ee-6-book/) do
[Antonio Goncalves](http://antoniogoncalves.org/) sobre [Java
EE](https://en.wikipedia.org/wiki/Java_EE) 6, e caí em cima. Tendo
recentemente terminado sua leitura, registro aqui minhas impressões a
respeito.

  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  [![Read the original, dude!](https://eljunior.files.wordpress.com/2013/01/intro-javaee.png?w=300)](https://www.amazon.com/Beginning-Java-Platform-GlassFish-Professional/dp/1430219548)
  Read the original, dude!
  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Antes de começar, porém, já adianto uma coisa: apesar do conteúdo do
livro ser bem decente, a tradução dele é **péssima**. Me encontrei
frequentemente tendo que adivinhar como seria o texto original em inglês
para poder compreender o traduzido, pois este não fazia nenhum sentido.
A impressão é que o livro foi traduzido por várias pessoas diferentes
(estagiários?), que não sabem muito sobre orientação a objetos e muito
menos da plataforma Java EE, resultando numa confusão de palavreado
mal-traduzido bem difícil de entender. Resumindo: a tradução atrapalha
muito mais do que ajuda! Se soubesse que seria tão desleixada, jamais
teria comprado o livro traduzido. Portanto, se você já lê inglês,
obtenha [a versão
original](https://www.amazon.com/Beginning-Java-Platform-GlassFish-Professional/dp/1430219548)
(mesmo que saia mais caro): você vai poupar sofrimento e a leitura será
mais tranquila. Se você não lê inglês, leia [a versão
original](https://www.amazon.com/Beginning-Java-Platform-GlassFish-Professional/dp/1430219548 "Beginning Java EE 6 Platform with Glassfish 3")
também e aproveite pra começar a aprender inglês logo: será mais
saudável pra sua carreira não depender de traduções fajutas! OK, fim da
reclamação.

O livro fornece uma visão geral da plataforma, e também tenta mostrar o
contexto histórico e motivações para o surgimento dos protocolos e APIs.
Após apresentar rapidamente o que consiste a plataforma e os programas
necessários para rodar os exemplos
([JDK](https://en.wikipedia.org/wiki/Java_Development_Kit),
[Maven](https://maven.apache.org/), [Glassfish
3](http://glassfish.java.net/), [Junit
4](https://en.wikipedia.org/wiki/JUnit) and
[Derby](http://db.apache.org/derby)), o livro começa a apresentar as
APIs e conceitos da plataforma numa abordagem meio *bottom-up*: alguns
capítulos sobre mapeamento objeto-relacional com
[JPA](https://en.wikipedia.org/wiki/Java_Persistence_API) -- a API
especificada para persistência com Java, depois alguns capítulos sobre
as partes de Java EE usadas principalmente para a lógica de negócio
([EJBs](https://en.wikipedia.org/wiki/Enterprise_JavaBeans), Transações,
[AOP](https://en.wikipedia.org/wiki/Aspect-oriented_programming) no
estilo Java EE com *Callbacks* e *Interceptors*), seguidos de uma visão
rápida das tecnologias usadas para a parte de apresentação na Web
([JSF](https://en.wikipedia.org/wiki/JavaServer_Faces),
[JSP](https://en.wikipedia.org/wiki/JavaServer_Pages), e assuntos
relacionados), e culmina com os últimos 3 capítulos dedicados a
comunicação entre sistemas: mensageria com
[JMS](https://en.wikipedia.org/wiki/Java_Message_Service), [Web Services
SOAP](https://en.wikipedia.org/wiki/Java_API_for_XML_Web_Services) e
[RESTful](https://en.wikipedia.org/wiki/Java_API_for_RESTful_Web_Services).

O conteúdo é bom pra *“designorantar-se”* dos conceitos e tecnologias
disponíveis na plataforma, acho que dá pra recomendar pra qualquer
pessoa envolvida com Java e ainda não conferiu o Java EE, ou que vem de
outras linguagens/frameworks e quer conhecer o padrão. Todavia, pelo que
tenho lido no StackOverflow e em alguns outros lugares, a API
especificada de Java EE sobre [Contextos e Injeção de
Dependência](http://docs.oracle.com/javaee/6/tutorial/doc/gjbnr.html)
(CDI, na sigla em inglês) vem ganhando cada vez mais importância na
plataforma, então é um certo pecado o livro simplesmente ignorá-la -- em
nenhum lugar do texto é sinalizado a omissão de uma parte importante da
coisa.

Gostei bastante da cobertura de JPA, relativamente bem completa para um
livro de introdução à plataforma. Rapidamente encontrei material pra uso
no meu trabalho. A seção sobre EJBs pra mim foi interessante para
comparar com a minha experiência com os recursos substitutos do
[Spring](https://en.wikipedia.org/wiki/Spring_Framework). (Parece que os
meus [SLSBs](https://en.wikipedia.org/wiki/Session_Beans#Stateless_Session_Beans)
são beans do Spring com
[@Transactional](http://static.springsource.org/spring/docs/2.5.x/api/org/springframework/transaction/annotation/Transactional.html).
:) As partes exclusivamente sobre JSF não me reservaram muitas
surpresas, mas curti aprender mais sobre o contexto histórico do
framework, com a seção descrevendo o surgimento de
[JSP](https://en.wikipedia.org/wiki/JavaServer_Pages),
[JSTL](https://en.wikipedia.org/wiki/JavaServer_Pages_Standard_Tag_Library),
[Facelets](https://en.wikipedia.org/wiki/Facelets),
[EL](https://en.wikipedia.org/wiki/Unified_Expression_Language), etc.
Achei muito boa também a exposição sobre a API Javascript que ganhou
especificação no JSF 2, usada para as requisições Ajax.

Por fim, os 3 últimos capítulos sobre interoperabilidade também estão
interessantes, embora eu me arrastei na leitura deles. Sobre JMS, não
tinha muita novidade (a API andou meio parada por algum tempo, e deverá
ter novidades no [Java EE 7](http://jcp.org/en/jsr/detail?id=342) com o
[JMS 2](http://jcp.org/en/jsr/detail?id=343)). Fato curioso: o capítulo
sobre serviços REST conseguiu ser mais enfadonho do que o de serviços
SOAP (e olha que eu tendo a favorecer REST). Começou entrando demais nos
conceitos dos protocolos antes de mostrar um exemplo prático que
demonstrasse as vantagens da coisa -- o que provavelmente teria criado
um engajamento melhor com a exposição da API. Mas bem, o estilo REST é
relativamente novo no mundo Java, talvez à medida que mais gente compre
a idéia, ele deve receber mais atenção no futuro.

Os exemplos do livro servem apenas como um chute inicial mesmo, é só pra
você ter uma idéia mesmo do que é possível de atingir com as APIs que
estão sendo explicadas. Quase nada dos códigos de exemplo parecem
aproveitáveis para uma aplicação real -- muito longe de código de
produção. Nesse sentido, o livro provavelmente não está longe da vasta
maioria das documentações técnicas para programadores, infelizmente.

Apesar de tudo, ler esse livro foi muito bom pra mim, pois expandiu um
bocado minha compreensão sobre algumas tecnologias que trabalho e sobre
as possibilidades da tal plataforma Java EE. E como uso bastante JPA e
JSF no meu trabalho atual, fiquei por dentro de vários recursos úteis
dessas APIs que eu desconhecia. Por exemplo, apesar de usar JPA há já
uns 2 anos, eu desconhecia os mecanismos de mapeamento com
[@ElementCollection](http://docs.oracle.com/javaee/6/api/javax/persistence/ElementCollection.html)
e
[@Embeddable](http://docs.oracle.com/javaee/6/api/javax/persistence/Embeddable.html).
Também, mesmo usando JSF há um bom tempo, desconhecia o
[composite:insertChildren](http://docs.oracle.com/javaee/6/javaserverfaces/2.0/docs/pdldocs/facelets/composite/insertChildren.html)
(meus olhos devem ter pulado essa tag na listagem da documentação mais
de uma vez). Essas e outras coisas encontraram uso bem rapidinho no
código da aplicação que estou trabalhando. Meio besta eu não saber disso
antes, né? Mas bem, isso é pra ser um dos benefícios esperados ao se
sentar pra ler uma josca dessas até o final. :)

No final, fiquei com uma sensação um pouco mais positiva em relação ao
Java EE (ou devo dizer, menos negativa?). Enfim, parece que do seu
próprio modo a plataforma está evoluindo, e as APIs estão ficando bem
decentes. E [a próxima versão Java EE
7](http://jcp.org/en/jsr/detail?id=342) parece que sairá em breve ([essa
página](http://jdevelopment.nl/open-source/java-ee-7-progress-page/)
tenta registrar o progresso), com mais melhorias em todas as áreas.
Contudo, às vezes tenho a impressão que o meu sentimento positivo é mais
devido ao péssimo estado anterior das APIs do que aos recursos
verdadeiros das versões atuais.

Pessoalmente, das tecnologias para aplicações Web do “mundo Java”, tendo
a gostar mais de coisas como o [Grails](http://grails.org/), que oferece
várias facilidades semelhantes aos da plataforma Java EE, mas com
usabilidade bem melhorada para mim como programador. Sei que não é muito
justo comparar, já que Java EE é um conjunto de especificações (tem
muita gente que valoriza isso), mas em termos de recursos disponíveis
para um programador construir um app, pode fazer bastante sentido
compará-los.

Finalmente, tem algumas coisas que me importam bastante num *toolkit*, e
que Java EE ainda precisa melhorar:

-   Facilidade de fazer bootstrap duma aplicação Web (IDEs e o Maven
    ajudam, mas ainda estão longe de *grails create-app NOME\_DO\_APP*)
-   Facilidade de instalar/publicar uma aplicação -- em especial,
    minimizando a quantidade de configuração a ser feita para os
    recursos que ela vai usar.
    -   Envolve colocar o máximo de configuração possível embutido na
        aplicação. Isso meio que bate de frente com a idéia prevalente
        do Java EE de que as configurações devem ser feitas no servidor
        de aplicação.
-   Suporte de primeira-classe a uma linguagem dinâmica nas partes em
    que faz mais sentido. (Groovy, Python, Ruby ou JavaScript já
    resolveriam pra mim, mas outras também serviriam).
-   Independência de IDE -- quero poder acionar facilmente a execução
    dos testes e geração de builds pela linha de comando. (Aqui usar uma
    ferramenta como o Maven ajuda bastante, mas ainda depende de muita
    configuração *boilerplate* -- e frequentemente, bastante esforço).

Concluindo, acho que é bem interessante conhecer o que o Java EE tem a
oferecer. Mas é bom não parar por aí: ainda tem
[bastante](http://www.playframework.org/) [coisa](http://torquebox.org/)
[interessante](http://grails.org/) [por](http://www.joodoweb.com/)
[aí](http://www.webnoir.org/) [pra](http://griffon.codehaus.org/)
[investigar](http://appfuse.org/).
