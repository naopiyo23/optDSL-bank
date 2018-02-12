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

#�`���[�j���O
tuneRF(rf_train_train, as.factor(y_train_train$y),doBest=TRUE)

rf<-randomForest(rf_train_train, #�w�K�f�[�^(�����ϐ�)
                 as.factor(y_train_train$y), #�w�K�f�[�^(�ړI�ϐ�)
                 mtry=8, #1�{�̖؂Ɏg�p����ϐ��̐�
                 sampsize=nrow(rf_train_train)*0.3, #���f���\�z�Ɏg�p����f�[�^��
                 nodesize=100, #��������e����؂̃m�[�h���܂ރT���v���ŏ���
                 maxnodes=30, #��������e����؂̏I�[�m�[�h�̍ő吔
                 ntree=5000, #�������錈��؂̐�
                 imprtance=T #�ϐ��d�v�x�̗L��
)

plot(rf)


##train_test��AUC
#prediction(�\������,�ړI�ϐ�(1 or 0))
pred <-predict(rf, newdata=rf_train_test, type="prob")[,2]
auc<-roc(y_train_test$y, pred)
print(auc)

##�ϐ��d�v�x
print(importance(rf))

##########################���e�p
#�\�z�f�[�^
rf_train<-train %>%
  dplyr::select(-id, -y)

#���؃f�[�^
rf_train_test<-test %>%
  dplyr::select(-id)

#�ړI�ϐ��쐬
y_train<- train %>%
  dplyr::select(y)

rf<-randomForest(rf_train, #�w�K�f�[�^(�����ϐ�)
                 as.factor(y_train$y), #�w�K�f�[�^(�ړI�ϐ�)
                 mtry=8, #1�{�̖؂Ɏg�p����ϐ��̐�
                 sampsize=nrow(rf_train)*0.3, #���f���\�z�Ɏg�p����f�[�^��
                 nodesize=100, #��������e����؂̃m�[�h���܂ރT���v���ŏ���
                 maxnodes=30, #��������e����؂̏I�[�m�[�h�̍ő吔
                 ntree=5000, #�������錈��؂̐�
                 imprtance=T #�ϐ��d�v�x�̗L��
)
pred <-predict(rf, newdata=test, type="prob")[,2]
#CSV�o��
submit1<-data.frame(id=test$id, score=pred)
write.table(submit1,
            file="C:/study/bank/submit/submit_train_20171103_RandomForest_2.csv",
            quote=F, sep=",", row.names=F, col.names=F)
