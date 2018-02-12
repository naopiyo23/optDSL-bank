##########�g�p���C�u����##########
library(dplyr)
library(xgboost)
library(caret)
library(pROC)

#�f�[�^�ǂݍ���
train<-read.csv("C:/study/bank/motodata/train.csv", header=T)
test<-read.csv("C:/study/bank/motodata/test.csv", header=TRUE)

#�J�e�S���[�ϐ��𐔒l�ϐ��ɕϊ�
train_v<-as.data.frame(predict(dummyVars(~.,data=train), train))
test_v<-as.data.frame(predict(dummyVars(~.,data=test), test))


#�ړI�ϐ��쐬
y_train <- train$y

#�s��ɕϊ�
x_train <-as.matrix(dplyr::select(train_v,-id,-y))
x_test <-as.matrix(dplyr::select(test_v,-id))

###Hold Out
#�\�z�f�[�^�̊���
rate<-0.7

#�\�z�f�[�^��(�����̐؎̂�)
num<-as.integer(nrow(x_train)*rate)

#�Č����̂��ߗ����V�[�h���Œ�
set.seed(17)

#sample(�x�N�g��, �����_���Ɏ擾�����, �������o�̗L��)
row<-sample(1:nrow(x_train), num, replace=FALSE)

#�\�z�f�[�^
x_train_train<-x_train[row,]

#���؃f�[�^
x_train_test<-x_train[-row,]

#�ړI�ϐ��쐬
y_train_train<- y_train[row]
y_train_test<- y_train[-row]

#�p�����[�^�̐ݒ�
set.seed(17)
param <- list(objective = "binary:logistic", #���W�X�e�B�b�N��A�Ŋm���o��
              eval_metric = "auc", #�]���w�W
              eta=0.07, #�w�K��
              max_depth=3, #����؂̊K�w
              min_child_weight=10, #�ŏ��m�[�h��
              colsample_bytree=0.4, #�g�p����ϐ�����
              gamma=0.9, #�����Ҍ��ŏ��l
              subsample=1 #�g�p����w�K�f�[�^����
)

#CV�ɂ��w�K���T��
xgbcv <- xgb.cv(param=param, data=x_train_train, label=y_train_train,
                nrounds=10000, #�w�K��
                nfold=5, #CV��
                nthread=1 #�g�p����CPU��
)

#���f���\�z
set.seed(17)
 model_xgb <- xgboost(param=param, data = x_train_train, label=y_train_train,
                      nrounds=which.max(xgbcv$evaluation_log$test_auc_mean), nthread=1, imprtance=TRUE)
# model_xgb <- xgboost(param=param, data = x_train_train, label=y_train_train,
#                      nrounds=10000, nthread=1, imprtance=TRUE)



#train_test��AUC
pred<-predict(model_xgb, x_train_test)
auc<-roc(y_train_test, pred)
print(auc)


#�ϐ��d�v�x
imp<- xgb.importance(names(dplyr::select(train_v,-id,-y)), model=model_xgb)
print(imp)


pred_test<-predict(model_xgb, x_test)
#CSV�o��
submit1<-data.frame(id=test$id, score=pred_test)
write.table(submit1,
            file="C:/study/bank/submit/submit_train_20171027_xgboost_3_10000.csv",
            quote=F, sep=",", row.names=F, col.names=F)
