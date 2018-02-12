#�g�p���C�u����
library(randomForest)
library(dplyr)
library(pROC)

#�f�[�^�ǂݍ���
train<-read.csv("c:/study/bank/motodata/train.csv", header=T)
test<-read.csv("C:/study/bank/motodata/test.csv", header=TRUE)

###Hold Out
#�\�z�f�[�^�̊���
rate<-0.7

#�\�z�f�[�^��(�����̐؎̂�)
num<-as.integer(nrow(train)*rate)

#�Č����̂��ߗ����V�[�h���Œ�
set.seed(17)

#sample(�x�N�g��, �����_���Ɏ擾�����, �������o�̗L��)
row<-sample(1:nrow(train), num, replace=FALSE)

#�\�z�f�[�^
rf_train_train<-train[row,] %>%
  dplyr::select(-id, -y)

#���؃f�[�^
rf_train_test<-train[-row,] %>%
  dplyr::select(-id, -y)

#�ړI�ϐ��쐬
y_train_train<- train[row,] %>%
  dplyr::select(y)
y_train_test<- train[-row,] %>%
  dplyr::select(y)

#�Č����̂��ߗ����V�[�h���Œ�
set.seed(17)
rf<-randomForest(rf_train_train, #�w�K�f�[�^(�����ϐ�)
                 as.factor(y_train_train$y), #�w�K�f�[�^(�ړI�ϐ�)
                 mtry=4, #1�{�̖؂Ɏg�p����ϐ��̐�
                 sampsize=nrow(rf_train_train)*0.3, #���f���\�z�Ɏg�p����f�[�^��
                 nodesize=100, #��������e����؂̃m�[�h���܂ރT���v���ŏ���
                 maxnodes=30, #��������e����؂̏I�[�m�[�h�̍ő吔
                 ntree=500, #�������錈��؂̐�
                 imprtance=T #�ϐ��d�v�x�̗L��
)

##train_test��AUC
#prediction(�\������,�ړI�ϐ�(1 or 0))
pred <-predict(rf, newdata=rf_train_test, type="prob")[,2]
auc<-roc(y_train_test$y, pred)
print(auc)

##�ϐ��d�v�x
print(importance(rf))


pred_test <-predict(rf, newdata=test, type="prob")[,2]
#CSV�o��
submit1<-data.frame(id=test$id, score=pred_test_m_logi1)
write.table(submit1,
            file="C:/study/bank/submit/submit_train_20171027_RandomForest_1.csv",
            quote=F, sep=",", row.names=F, col.names=F)
