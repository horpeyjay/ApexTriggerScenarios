public with sharing class PositionHandler {
    public static void autoPopulate(List<Position__c> positionList){
        /** Assignment 32
         * Upon Creation of Position (Custom Object) if it is a New Position and Open Date,Min Pay & Max Pay are not populated then populated with below values:
            a. Open Date = Today’s Date
            b. Min Pay = 10000
            c. Max Pay = 15000.
         */
        if(!positionList.isEmpty()){
            for(Position__c pos : positionList){
                if(pos.Open_Date__c == null && pos.Maximum_Pay__c == null && pos.Minimum_Pay__c == null){
                    pos.Open_Date__c = Date.today();
                    pos.Maximum_Pay__c = 15000;
                    pos.Minimum_Pay__c = 10000;
                }
            }
        }
    }
}