Title: Por que as estimativas em desenvolvimento de software normalmente estão erradas por um fator de 2-3?
Date: 2013-02-26 06:34
Author: Elias Dorneles
Slug: Por-que-as-estimativas-em-desenvolvimento-de-software-normalmente-estão erradas-por-um-fator-de-2-3?

> Aviso 1: Esta é uma tradução livre de uma das melhores histórias sobre
> estimativas de software já escritas. O original em inglês é uma
> [resposta no Quora à pergunta do
> título](http://www.quora.com/Engineering-Management/Why-are-software-development-task-estimations-regularly-off-by-a-factor-of-2-3),
> e essa tradução foi realizada com o consentimento do autor [Michael
> Wolfe](http://about.me/michaelrwolfe "Michael Wolfe"). Caso a língua
> não seja problema, recomendamos fortemente a leitura do texto
> original... simplesmente melhor e mais engraçado.
>
> Aviso 2: Este post é resultado duma colaboração minha com o senhor
> Crineu Tres. Isto é, ele fez tudo e eu só traduzi os palavrões.

Vamos dar uma caminhada saindo da costa de San Francisco até Los Angeles
para visitar nossos amigos em Newport Beach. Pego meu mapa e desenho
nossa rota pela costa:

![1](https://eljunior.files.wordpress.com/2013/02/1.png)  
O percurso é de aproximadamente 400 milhas; podemos caminhar 4 milhas
por hora, 10 horas por dia. Dessa forma chegaremos lá em 10 dias.
Ligamos para nossos amigos e marcamos uma janta para o próximo domingo
às 18h, quando chegaremos de forma triunfante! Eles mal podem esperar!

Acordamos cedo no dia seguinte altamente motivados para essa nova
aventura. Colocamos as mochilas, pegamos o mapa e a rota para o primeiro
dia. Olhamos então para o mapa. Ai ai:

[![2](https://eljunior.files.wordpress.com/2013/02/2.png)](https://eljunior.files.wordpress.com/2013/02/2.png)  
Caramba, a costa tem um milhão de curvas e reentrâncias! Com apenas um
dia de caminhada de 40 milhas não chegaremos nem em Half Moon Bay. Essa
viagem tem pelo menos 500 milhas, e não 400! Ligamos para nossos amigos
e atrasamos o jantar para a terça-feira. É melhor sermos realistas. Eles
ficam meio desapontados, mas não vêem a hora de chegarmos. Além disso,
12 dias de San Francisco até Los Angeles não é um tempo ruim.

Bem, com essa inconveniência resolvida, partimos. Duas horas mais tarde,
não passamos nem do zoológico. Qual o problema? Olhamos novamente para
nossa trilha:

[![3](https://eljunior.files.wordpress.com/2013/02/3.jpg)](https://eljunior.files.wordpress.com/2013/02/3.jpg)

Jesus, essa trilha não é fácil! Areia, água, escadas, riachos, lobos
marinhos furiosos! Estamos caminhando a no máximo 2 milhas por hora,
metade da velocidade pretendida... podemos então começar a caminhar 20
horas por dia ou ligar para nossos amigos e atrasar a janta mais uma
semana. Ok, vamos dividir o fardo: caminharemos 12 horas por dia e
atrasaremos a janta até o final de semana seguinte. Ligamos para nossos
amigos e remarcamos o jantar até o domingo seguinte. Eles ficam um pouco
irritados, mas confirmam o evento mesmo assim.

Montamos acampamento em Moss Beach após um dia duro de doze horas
caminhando. Cacilda, como é difícil montar barracas nesse vento! Não
conseguimos dormir antes da meia noite. Nada demais: iremos apertar o
passo amanhã.

Dormimos demais e acordamos doídos e cansados às.. 10 da manhã. Caralho!
Sem condições de fazer 12 horas hoje! Vamos caminhar 10 e compensaremos
com 14 amanhã. Juntamos os equipamentos e partimos.

Após um esforço redobrado nas primeiras horas, percebo nosso colega
mancando. Maravilha, bolhas nos pés... precisamos resolver isso agora.
Somos do tipo de grupo que resolve os problema individuais antes que
comecem a nos atrasar. Eu corro por 45 minutos, 3 milhas para longe da
costa até Pescadero, pego alguns band-aids e corro de volta para medicar
meu colega. Chego exausto e o sol está se pondo, então declaramos o dia
encerrado. Vamos dormir após fazer míseras 6 milhas. Mas temos
suprimentos novos. Ficaremos bem. Compensaremos amanhã.

Acordamos na manhã seguinte, protegemos nossos pés de futuras bolhas e
começamos a caminhar. Contornamos a encosta. Que?! Que porra é essa?

[![4](https://eljunior.files.wordpress.com/2013/02/4.jpg)](https://eljunior.files.wordpress.com/2013/02/4.jpg)

O maldito mapa não mostra essa merda! Temos que caminhar 3 milhas para o
interior, contornar uma propriedade federal rodeada por cercas, nos
perder duas vezes, e somente então voltar à costa em torno do meio-dia.
A maior parte do dia foi gasta para realizar 1 milha de progresso. Ok,
**não** ligaremos para nossos amigos para atrasar mais uma vez a janta.
Caminharemos até meia-noite para voltar ao planejamento inicial.

Após uma terrível noite de sono sob a névoa, meu amigo acorda com uma
dor de cabeça infernal e febre. Pergunto se ele consegue continuar e ele
responde: *"O que você acha, panaca? Estou caminhando nessa névoa gelada
por 3 dias sem descanso!"*. Beleza... o dia de hoje está perdido. Vamos
descansar e nos recuperar. A partir de amanhã faremos 14 horas por dia,
já que estaremos descansados e preparados para tudo... são apenas mais
alguns dias, então obviamente podemos cumprir o prazo!

Acordamos moídos no dia seguinte. Olho o mapa:

![5](https://eljunior.files.wordpress.com/2013/02/5.png)

Puta merda! Estamos no dia 5 de uma viagem de 10 dias e não saímos nem
da Bay Area! Isso é patético! Vamos trabalhar em uma estimativa mais
precisa e ligar para nossos amigos. Provavelmente seremos repreendidos,
mas teremos uma data realista pelo menos.

Meu amigo diz: *"Bem, fizemos 40 milhas em 4 dias, e é uma viagem de
pelo menos 600 milhas, então são 60 dias, provavelmente 70 considerando
uma margem para imprevistos"*. Eu respondo *"Nem fu...... Ok, eu posso
nunca ter feito essa caminhada antes, mas eu **sei** que não demora 70
dias para caminhar de São Francisco até Los Angeles. Nossos amigos irão
rir de nós se ligarmos avisando que só chegaremos na Páscoa!"*

E continuo: *"Se vocês se comprometerem a caminhar 16 horas por dia,
podemos compensar o tempo perdido! Sei que será difícil, mas essa é a
reta final!"*. Meu colega grita de volta: *"Pra começo de conversa, não
fui eu que liguei dizendo que estaríamos lá no Domingo, tá? Você está
acabando com a gente por um erro seu!"*

Um silêncio tenso recai sobre o grupo. A ligação não é realizada.
Ligarei amanhã, quando meu camarada voltar às suas faculdades mentais e
concordar em algo razoável.

Na manhã seguinte aguardamos em nossas barracas até o temporal passar.
Levantamos acampamento e saímos às 10h, esticando músculos doídos e
novas bolhas nos pés. Não comentamos nada sobre a briga do dia anterior,
embora eu tenha xingado um certo colega idiota que esqueceu a garrafa de
água e fez a gente gastar 30 minutos para buscá-la.

Faço uma nota mental lembrando que estamos sem papel higiênico e
precisamos parar na cidade mais próxima. Contornamos a enseada: um rio
está bloqueando nosso caminho. Sinto uma forte dor-de-barriga e a
sensação de diarréia iminente...
