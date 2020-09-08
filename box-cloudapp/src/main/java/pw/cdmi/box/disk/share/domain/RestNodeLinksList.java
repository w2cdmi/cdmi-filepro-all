package pw.cdmi.box.disk.share.domain;

import java.io.Serializable;
import java.util.List;

public class RestNodeLinksList implements Serializable
{
    private static final long serialVersionUID = 2979950377700646656L;
    
    private List<INodeLinkV2> links;
    
    private Long totalCount;
    
    public List<INodeLinkV2> getLinks()
    {
        return links;
    }
    
    public void setLinks(List<INodeLinkV2> links)
    {
        this.links = links;
    }
    
    public Long getTotalCount()
    {
        return totalCount;
    }
    
    public void setTotalCount(Long totalCount)
    {
        this.totalCount = totalCount;
    }
}
