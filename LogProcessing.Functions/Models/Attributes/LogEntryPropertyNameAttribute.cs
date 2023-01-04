using System;

namespace LogProcessing.Functions.Models.Attributes;

public class LogEntryPropertyNameAttribute : Attribute
{
    public LogEntryPropertyNameAttribute(string propertyName)
    {
        PropertyName = propertyName;
    }

    public string PropertyName { get; }
}