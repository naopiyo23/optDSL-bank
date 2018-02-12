#�������f���̑g�ݍ��킹�i���ρj

####################submit_20171103_1_logi#######################################################
#�g�p���C�u����
library(pROC)
library(dplyr)
library(ggplot2)

#�f�[�^�Ǎ�
train<-read.csv("C:/study/bank/motodata/train.csv", header=T)
test<-read.csv("C:/study/bank/motodata/test.csv", header=T)

##########�ϐ����H##########

#age���`���̊m�F
check<-train %>%
  #�N�ゲ�Ƃ̑ΐ��I�b�Y���v�Z
  dplyr::mutate(age_c = floor(age/10)*10)%>% 
  #�J�e�S���ǉ��A10���A�؎�
  dplyr::group_by(age_c) %>%
  #�O���v�ƃA���O���v�̓Z�b�g
  dplyr::summarise(p=mean(y)) %>%
  dplyr::ungroup(.) %>%
  dplyr::mutate(log_odds=log(p/(1-p)))

#�O���t�̏o��
g<-ggplot(check, aes(x=age_c, y=log_odds)) + geom_line()
plot(g)

#�ϐ����H(age��50�Ő܂�Ԃ�)
train2<-train %>%
  #abs�͐�Βl
  dplyr::mutate(age2=abs(50-age))

#�Ăѐ��`���̊m�F
check<-train2 %>%
  #age2�ł̔N�ゲ�Ƃ̑ΐ��I�b�Y���v�Z
  dplyr::mutate(age_c = floor(age2/10)*10) %>%
  dplyr::group_by(age_c) %>%
  dplyr::summarise(p=mean(y)) %>%
  dplyr::ungroup(.) %>%
  dplyr::mutate(log_odds=log(p/(1-p)))

#�O���t�̏o��
g<-ggplot(check, aes(x=age_c, y=log_odds)) + geom_line()
plot(g)

#�O��l���ۂ߂�
#balance�O��l�̊m�F
hist(train2$balance)

#�p�[�Z���^�C���_�̊m�F

#�ۂ�(ifelse(������, �^�̂Ƃ��Ԃ��l, �U�̂Ƃ��Ԃ��l)) quantile���������ŉ��p�[�Z���g����Ԃ�
train2<-train2 %>%
  dplyr::mutate(balance2=ifelse(balance >= quantile(balance,probs=.95),
                                quantile(balance,probs=.95),
                                balance))
#�O��l�̊m�F
hist(train2$balance2)

#���֌W���̊m�F
cor(train2[,c("age2", "balance2")])

#�O��l�̊m�F
hist(train2$balance)
hist(train2$duration)
hist(train2$campaign)
hist(train2$pdays)
hist(train2$previous)

#�p�[�Z���^�C���_�̊m�F

#�ۂ�(ifelse(������, �^�̂Ƃ��Ԃ��l, �U�̂Ƃ��Ԃ��l)) quantile���������ŉ��p�[�Z���g����Ԃ�
train2<-train2 %>%
  dplyr::mutate(balance2=ifelse(balance >= quantile(balance,probs=.95),
                                quantile(balance,probs=.95),
                                balance))
train2<-train2 %>%
  dplyr::mutate(duration2=ifelse(duration >= quantile(duration,probs=.95),
                                 quantile(duration,probs=.95),
                                 duration))
train2<-train2 %>%
  dplyr::mutate(campaign2=ifelse(campaign >= quantile(campaign,probs=.95),
                                 quantile(campaign,probs=.95),
                                 campaign))
train2<-train2 %>%
  dplyr::mutate(pdays2=ifelse(pdays >= quantile(pdays,probs=.95),
                              quantile(pdays,probs=.95),
                              pdays))
train2<-train2 %>%
  dplyr::mutate(previous2=ifelse(previous >= quantile(previous,probs=.95),
                                 quantile(previous,probs=.95),
                                 previous))
#�O��l�̊m�F
hist(train2$balance2)
hist(train2$duration2)
hist(train2$campaign2)
hist(train2$pdays2)
hist(train2$previous2)

#test�ɂ�train�Ɠ��l�̉��H
test2<-test %>%
  dplyr::mutate(age2=abs(50-age),
                balance2=ifelse(balance >= quantile(balance,probs=.95),
                                quantile(balance,probs=.95),
                                balance),
                duration2=ifelse(duration >= quantile(duration,probs=.95),
                                 quantile(duration,probs=.95),
                                 duration),
                campaign2=ifelse(campaign >= quantile(campaign,probs=.95),
                                 quantile(campaign,probs=.95),
                                 campaign),
                pdays2=ifelse(pdays >= quantile(pdays,probs=.95),
                              quantile(pdays,probs=.95),
                              pdays),
                previous2=ifelse(previous >= quantile(previous,probs=.95),
                                 quantile(previous,probs=.95),
                                 previous))

# train<-train2
# test<-test2
# train<-dplyr::select(train2,-age,-balance)
# test<-dplyr::select(test2,-age,-balance)
train<-dplyr::select(train2,-age,-balance,-duration,-campaign,-pdays,-previous)
test<-dplyr::select(test2,-age,-balance,-duration,-campaign,-pdays,-previous)
##########�ϐ����H##########


# ###�X�e�b�v���C�Y�@ AIC�Ŕ��f�A�T���I
# logi_model_all <- glm(
#   y ~ .,    #�ړI�ϐ��Ɛ����ϐ��̎w��(�S�Ďg���ꍇ��y~.)
#   data=train,             #�w�K�f�[�^
#   family=binomial(link="logit") #���W�X�e�B�b�N��A���w��
# )
# 
# #�X�e�b�v���C�Y
# step.model_all <- step(logi_model_all)
# 
# #�I�����ꂽ�ϐ��̊m�F
# summary(step.model_all)
# 



#���x�m�F�̂���Hold Out
rate<-0.7
num<-as.integer(nrow(train)*rate)
set.seed(17)
row<-sample(1:nrow(train), num, replace=FALSE)

train_train<-train[row,]
train_test<-train[-row,]

logi_model<- glm(
  y ~ job + marital + education + housing + loan + contact + day + 
    month + poutcome + age2 + balance2 + duration2 + campaign2 + 
    pdays2 + previous2,    #�ړI�ϐ��Ɛ����ϐ��̎w��(�S�Ďg���ꍇ��y~.)
  data=train_train,             #�w�K�f�[�^
  family=binomial(link="logit") #���W�X�e�B�b�N��A���w��
)

#���f���̒��g������
summary(logi_model)

#���f���̐��x�m�F
#���f���̓��Ă͂�
pred_train_test<- predict(logi_model, newdata=train_test, type="response")

#AUC�m�F
auc<-roc(train_test$y, pred_train_test)$auc
auc


###Submit
logi_model2 <- glm(
  y ~ job + marital + education + housing + loan + contact + day + 
    month + poutcome + age2 + balance2 + duration2 + campaign2 + 
    pdays2 + previous2,    #�ړI�ϐ��Ɛ����ϐ��̎w��(�S�Ďg���ꍇ��y~.)
  data=train,             #�w�K�f�[�^
  family=binomial(link="logit") #���W�X�e�B�b�N��A���w��
)


pred_logi <- predict(logi_model2, newdata=test, type="response")

#submit�̌`���ŏo��(CSV)
#�f�[�^���H
out<-data.frame(test2$id, pred_logi)

# #�o��
# write.table(out, #�o�̓f�[�^
#             "C:/study/bank/submit/submit_20171103_1_logi.csv", #�o�͐�
#             quote=FALSE, #��������u"�v�ň͂ޗL��
#             col.names=FALSE, #�ϐ���(��)�̗L��
#             row.names=FALSE, #�s�ԍ��̗L��
#             sep="," #��؂蕶���̎w��
# )

####################submit_train_20171103_RandomForest_1#######################################################

#�g�p���C�u����
library(randomForest)
library(dplyr)
library(pROC)

#�f�[�^�ǂݍ���
train<-read.csv("c:/study/bank/motodata/train.csv", header=T)
test<-read.csv("C:/study/bank/motodata/test.csv", header=TRUE)

# ###Hold Out
# #�\�z�f�[�^�̊���
# rate<-0.7
# 
# #�\�z�f�[�^��(�����̐؎̂�)
# num<-as.integer(nrow(train)*rate)
# 
# #�Č����̂��ߗ����V�[�h���Œ�
# set.seed(17)
# 
# #sample(�x�N�g��, �����_���Ɏ擾�����, �������o�̗L��)
# row<-sample(1:nrow(train), num, replace=FALSE)
# 
# #�\�z�f�[�^
# rf_train_train<-train[row,] %>%
#   dplyr::select(-id, -y)
# 
# #���؃f�[�^
# rf_train_test<-train[-row,] %>%
#   dplyr::select(-id, -y)
# 
# #�ړI�ϐ��쐬
# y_train_train<- train[row,] %>%
#   dplyr::select(y)
# y_train_test<- train[-row,] %>%
#   dplyr::select(y)
# 
# #�Č����̂��ߗ����V�[�h���Œ�
# set.seed(17)
# rf<-randomForest(rf_train_train, #�w�K�f�[�^(�����ϐ�)
#                  as.factor(y_train_train$y), #�w�K�f�[�^(�ړI�ϐ�)
#                  mtry=4, #1�{�̖؂Ɏg�p����ϐ��̐�
#                  sampsize=nrow(rf_train_train)*0.3, #���f���\�z�Ɏg�p����f�[�^��
#                  nodesize=100, #��������e����؂̃m�[�h���܂ރT���v���ŏ���
#                  maxnodes=30, #��������e����؂̏I�[�m�[�h�̍ő吔
#                  ntree=5000, #�������錈��؂̐�
#                  imprtance=T #�ϐ��d�v�x�̗L��
# )
# 
# ##train_test��AUC
# #prediction(�\������,�ړI�ϐ�(1 or 0))
# pred <-predict(rf, newdata=rf_train_test, type="prob")[,2]
# auc<-roc(y_train_test$y, pred)
# print(auc)

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
                 mtry=4, #1�{�̖؂Ɏg�p����ϐ��̐�
                 sampsize=nrow(rf_train)*0.3, #���f���\�z�Ɏg�p����f�[�^��
                 nodesize=100, #��������e����؂̃m�[�h���܂ރT���v���ŏ���
                 maxnodes=30, #��������e����؂̏I�[�m�[�h�̍ő吔
                 ntree=5000, #�������錈��؂̐�
                 imprtance=T #�ϐ��d�v�x�̗L��
)
pred_rf <-predict(rf, newdata=test, type="prob")[,2]
# #CSV�o��
# submit1<-data.frame(id=test$id, score=pred)
# write.table(submit1,
#             file="C:/study/bank/submit/submit_train_20171103_RandomForest_1.csv",
#             quote=F, sep=",", row.names=F, col.names=F)


####################submit_train_20171103_RandomForest_1#######################################################


####################submit_train_20171103_xgboost_#######################################################
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


#train_test��AUC
pred<-predict(model_xgb, x_train_test)
auc<-roc(y_train_test, pred)
print(auc)


#�ϐ��d�v�x
imp<- xgb.importance(names(dplyr::select(train_v,-id,-y)), model=model_xgb)
print(imp)


pred_xgb<-predict(model_xgb, x_test)
#CSV�o��
# submit1<-data.frame(id=test$id, score=pred_xgb)
# write.table(submit1,
#             file="C:/study/bank/submit/submit_train_20171103_xgboost_.csv",
#             quote=F, sep=",", row.names=F, col.names=F)

####################submit_train_20171103_xgboost_#######################################################
#submit�̌`���ŏo��(CSV)
#�f�[�^���H
out<-data.frame(test$id, (pred_logi+4*pred_rf+6*pred_xgb)/10)
write.table(out,
            file="C:/study/bank/submit/submit_train_20171103_R_3.csv",
            quote=F, sep=",", row.names=F, col.names=F)
