package com.huawei.sharedrive.uam.statistics.domain;

import com.huawei.sharedrive.uam.openapi.domain.TimePoint;

public class ObjectHistoryStatisticsInfo
{
    
    private Long actualFileCount;
    
    private Long actualSpaceUsed;
    
    private Long addedActualFileCount;
    
    private Long addedActualSpaceUsed;
    
    private Long addedFileCount;
    
    private Long addedSpaceUsed;
    
    private Long fileCount;
    
    private Long spaceUsed;
    
    private TimePoint timePoint;
    
    public Long getActualFileCount()
    {
        return actualFileCount;
    }
    
    public void setActualFileCount(Long actualFileCount)
    {
        this.actualFileCount = actualFileCount;
    }
    
    public Long getActualSpaceUsed()
    {
        return actualSpaceUsed;
    }
    
    public void setActualSpaceUsed(Long actualSpaceUsed)
    {
        this.actualSpaceUsed = actualSpaceUsed;
    }
    
    public Long getAddedActualFileCount()
    {
        return addedActualFileCount;
    }
    
    public void setAddedActualFileCount(Long addedActualFileCount)
    {
        this.addedActualFileCount = addedActualFileCount;
    }
    
    public Long getAddedActualSpaceUsed()
    {
        return addedActualSpaceUsed;
    }
    
    public void setAddedActualSpaceUsed(Long addedActualSpaceUsed)
    {
        this.addedActualSpaceUsed = addedActualSpaceUsed;
    }
    
    public Long getAddedFileCount()
    {
        return addedFileCount;
    }
    
    public void setAddedFileCount(Long addedFileCount)
    {
        this.addedFileCount = addedFileCount;
    }
    
    public Long getAddedSpaceUsed()
    {
        return addedSpaceUsed;
    }
    
    public void setAddedSpaceUsed(Long addedSpaceUsed)
    {
        this.addedSpaceUsed = addedSpaceUsed;
    }
    
    public Long getFileCount()
    {
        return fileCount;
    }
    
    public void setFileCount(Long fileCount)
    {
        this.fileCount = fileCount;
    }
    
    public Long getSpaceUsed()
    {
        return spaceUsed;
    }
    
    public void setSpaceUsed(Long spaceUsed)
    {
        this.spaceUsed = spaceUsed;
    }
    
    public TimePoint getTimePoint()
    {
        return timePoint;
    }
    
    public void setTimePoint(TimePoint timePoint)
    {
        this.timePoint = timePoint;
    }
}
