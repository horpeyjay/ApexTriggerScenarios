trigger PositionTrigger on Position__c (before insert) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            PositionHandler.autoPopulate(trigger.new);
        }
    }
}