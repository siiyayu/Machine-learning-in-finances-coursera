
//определяется тип данных
data {
    int N1;        //число наблюдений в обучающей выборке
    real x1[N1];   //факторы - в нашем случае время
    vector[N1] y1; //наблюдаемые величины в обучающей выборке
    int N2;        //число наблюдений в тестовой выборке
    real x2[N2];   //факторы на тестовой выборке - в нашем случае время в будущем  
}

//генерируются данные внутри программы, или обрабатывается, то что определено в блоке data
transformed data{ 
    vector[N1] mu = rep_vector(.0, N1); //нулевой уровень, вокруг которого строится гауссовский процесс
}


//параметры модели, - в нашем случае гиперпараметры ядра
parameters {              //параметры ядра
    real<lower=0> a;      //амплитуда RBF ядра
    real<lower=0> l;      //эффективная длина RBF ядра
    real<lower=0> sigma;  //ошибка регрессии
    
}

//параметры могут обрабатываться
transformed parameters{
    matrix[N1,N1] K; //матрица ковариации для обучающей выборки
    
    for (i in 2:N1)
        for(j in 1:(i-1))
        {
            K[i,j] = square(a) * exp(-square(x1[i]-x1[j])*inv_square(l*365)*0.5 );
            K[j,i] = K[i,j]; // делаем ее симметричной
        }
    
    for (n in 1:N1)
        K[n,n] = square(a) +
                 square(sigma) +   
                 1e-12;    // слагаемое для того, чтобы матрица всегда оставалась положительно определенной на этапе оптимизации
}

// В этом блоке связываются параметры и данные через распределения. Stan авто-
// матически строит функции правдоподобия и оптимизирует параметры распределения. 
// Дополнительно, можно добавлять приорные распределения для параметров модели
model { 
    
    
    y1 ~ multi_normal(rep_vector(0,N1),K); 
    
    
    a ~ normal(0, 1);  //приорное распределение магнитуды колебания ряда
    l ~ lognormal(2, .1); // приорное распределение эф. длины
                          // нас интересует глобальный тренд, поэтому мы определили распределение подальше от нуля. 
                          // приорные распределения выставляются на "глаз", чтобы подсказать оптимизатору какого порядка должны быть параметры
    
}

//В блоке генерируются значения на основе оцененных параметров

generated quantities{
matrix[N2,N1] Kstar; //матрица ковариации между факторами прогнозными и факторами обучающими
vector[N2] yforecasted; //прогноз
    for (i in 1:N2)
        for(j in 1:N1)
            Kstar[i,j] = square(a) * exp(-square(x2[i]-x1[j]) * inv_square(l*365) * 0.5);
    
yforecasted = Kstar * (K\y1); //предскажем прогнозное среднее    
}
