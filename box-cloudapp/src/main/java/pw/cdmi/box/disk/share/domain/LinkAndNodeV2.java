package pw.cdmi.box.disk.share.domain;

import pw.cdmi.box.disk.client.domain.node.RestFolderInfo;

public class LinkAndNodeV2
{
    
    private INodeLinkV2 link;
    
    private RestFileInfoV2 file;
    
    private RestFolderInfo folder;
    
    public INodeLinkV2 getLink()
    {
        return link;
    }
    
    public void setLink(INodeLinkV2 link)
    {
        this.link = link;
    }
    
    public RestFileInfoV2 getFile()
    {
        return file;
    }
    
    public void setFile(RestFileInfoV2 file)
    {
        this.file = file;
    }
    
    public RestFolderInfo getFolder()
    {
        return folder;
    }
    
    public void setFolder(RestFolderInfo folder)
    {
        this.folder = folder;
    }
    
}
