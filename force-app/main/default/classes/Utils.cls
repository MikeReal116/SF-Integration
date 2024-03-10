public with sharing class Utils {
    public static final Integer CREATED = 201;
    public static final Integer INTERNAL_SERVER_ERROR = 500;
    public enum LogType {
        ERROR,
        INFO
    }

    public static Logger__c createLog(LogType logType, String message, String stackTrace) {
        Logger__c log = new Logger__c();
        log.Message__c = message;
        log.Type__c = logType.name();
        log.Stack_Trace__c = stackTrace;
        return log;
    }
}
