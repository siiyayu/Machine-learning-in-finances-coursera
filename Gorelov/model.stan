
//определяем тип данных для модели

data{
    int<lower=0> N; // длина обучающей выборки
    int<lower=0> D; // количество факторов
    int<lower=0> P; // длина тестовой выборки
    real y[N]; // целевая переменная из обучающей выборки
    real x[D,N+P]; // матрица факторов
}

parameters{ //задаем параметры
    real alpha[D];//коэффициенты линейной регрессии
    real s[N]; //сезонная составляющая
    real sigma; //ошибка регрессии
    real sigma2; //ошибка сезонной составляющей
}


model{ // модель представляет собой: y = (факторы * коэф) + сезонная составляющая + ошибки
    for (i in 1:N){
        real prd;
        prd =0;
        for(j in 1:D)  prd=prd+x[j,i]*alpha[j]; #

        y[i]~normal(prd+s[i], sigma); //y = (факторы*коэф) + сезонность + ошибка
    }

    
//------------Задание!!!!!!!: дописать слагаемые, описывающие сезонность----------
//------------сумма сезонных приростов за каждый месяц в сумме должна равняться 0---------
//   s[n] ~ Normal(s[n-11]+..+s[n-1],sigma2); 
    
   for (k in 12:N){           
 //...............................................      
       real prd;
       prd = 0;
       for (l in 1:11) prd = prd - s[k-l];
       s[k]~normal(prd,sigma2);
   }
//---------------------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!------------------------

}

generated quantities{
    real predY[N+P];
    real predS[N+P];
    for(k in 1:11) predS[k] = s[k];
    for (k in 12:N+P){
        real prd;
        prd =0;
        for(l in 1:11) prd=prd-predS[k-l];

        predS[k] = normal_rng(prd,sigma2);
    }

    for(i in 1:N+P){
        real prd;
        prd =0;
        for(j in 1:D)  prd=prd+x[j,i]*alpha[j];
        predY[i] = prd+predS[i];


    }
}