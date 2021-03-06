### aln.tools.R -- Alignment tools for R ###
###  written by Greg Jordan, fall 2008   ###
###  email: greg@ebi.ac.uk               ###

colorSequence = function(charList,type="protein",colors=NULL)
{
   colorMeDNA = function(char) {
     str = switch(EXPR=char,
       G = "#FFFF00",
       C = "#00FF00",
       T = "#FF0000",
       A = "#0000FF",
       "#000000"
     )
     return(str)
   }
   colorMeProtein = function(char) {
     # Protein colors taken from: http://jmol.sourceforge.net/jscolors/
     str = switch(EXPR=char,
       A = "#B8B8B8",       a = "#B8B8B8",
       C = "#E6E600",       c = "#E6E600",
       D = "#E60A0A",       d = "#E60A0A",
       E = "#E60A0A",       e = "#E60A0A",
       F = "#3232AA",       f = "#3232AA",
       G = "#C8C8C8",       g = "#C8C8C8",
       H = "#8282D2",       h = "#8282D2",
       I = "#0F820F",       i = "#0F820F",
       K = "#145AFF",       k = "#145AFF",
       L = "#0F820F",       l = "#0F820F",
       M = "#E6E600",       m = "#E6E600",
       N = "#00DCDC",       n = "#00DCDC",
       P = "#DC9682",       p = "#DC9682",
       Q = "#E60A0A",       q = "#E60A0A",
       R = "#145AFF",       r = "#145AFF",
       S = "#FA9600",       s = "#FA9600",
       T = "#FA9600",       t = "#FA9600",
       V = "#C8C8C8",       v = "#C8C8C8",
       W = "#C8C8C8",       w = "#C8C8C8",
       Y = "#C8C8C8",       y = "#C8C8C8",
       '2' = "#888888",       '2' = "#888888",
       O = "#424242",       o = "#424242",
       B = "#7D7D7D",       b = "#7D7D7D",
       Z = "#EEEEEE",       z = "#EEEEEE",
       "#000000"
     )

     # Taken from Taylor (97)
     taylor = switch(EXPR=char,
       P = "#ffcc00",       p = "#ffcc00",
       G = "#ff9900",       g = "#ff9900",
       A = "#ccff00",       a = "#ccff00",
       S = "#ff6600",       s = "#ff6600",
       T = "#ff6600",       t = "#ff6600",
       C = "#ffff00",       c = "#ffff00",
       V = "#99ff00",       v = "#99ff00",
       I = "#66ff00",       i = "#66ff00",
       L = "#00ff66",       l = "#00ff66",
       M = "#00ff00",       m = "#00ff00",
       F = "#00ff66",       f = "#00ff66",
       Y = "#00ffcc",       y = "#00ffcc",
       W = "#00ccff",       w = "#00ccff",
       H = "#0066ff",       h = "#0066ff",
       R = "#0000ff",       r = "#0000ff",
       K = "#6600ff",       k = "#6600ff",
       Q = "#ff00cc",       q = "#ff00cc",
       N = "#cc00ff",       n = "#cc00ff",
       D = "#ff0000",       d = "#ff0000",
       E = "#ff0033",       e = "#ff0033",
       O = "#808080",       o = "#808080",
       B = "#C0C0C0",       b = "#C0C0C0",
       Z = "#EEEEEE",       z = "#EEEEEE",
       "#000000"
       )

     return(taylor)
   }

   if (!is.null(colors)) {
     return(colors)
   }
   # Just do the default coloring.
   if (type == "protein")
   {
     cols = apply(as.matrix(charList),1,colorMeProtein)
   } else
   { 
     cols = apply(as.matrix(charList),1,colorMeDNA)
   }
   return(cols)
}

read.aln = function(file,
  seqType='auto') # 'auto', 'dna' or 'protein'
{
  # Do some parsing of the fasta file.
  fasta = read.table(file,header=FALSE,fill=TRUE,stringsAsFactors=FALSE,strip.white=TRUE)

  # Combine sequence rows.
  concatSeq = function(x,y)
  {
    nRow = length(x)
    if (nRow == 0 || length(x[nRow]) == 0)
    {
      return(c(x,y))
    }
    if (substr(x[nRow],1,1) == '>' || substr(y,1,1) == '>')
    {
      return(c(x,y))
    } else
    {
      x[nRow] = paste(x[nRow],y,sep="")
      return(x)
    }
  }
  fasta = Reduce(concatSeq,unlist(fasta),init=c(),accumulate=FALSE)
  len = length(fasta)
  names = fasta[seq(1,len,2)]
  names = substr(names,2,1048)
  seqs  = fasta[seq(2,len,2)]

  numRows = length(seqs)
  numCols = nchar(seqs[1])

  chars = strsplit(seqs,"")
  charMat = as.matrix(chars)
  arr= matrix(unlist(chars),
       nrow=length(chars),
       ncol=length(chars[[1]]),
       byrow=TRUE)

  # Figure out the sequence type by counting AGCTs.
  list = arr[1,]
  Ngaps = length(list[list=='-'])
  llen = length(list) - Ngaps
  As = length(list[list=='A' | list=='a']) / llen
  Gs = length(list[list=='G' | list=='g']) / llen
  Cs = length(list[list=='C' | list=='c']) / llen
  Ts = length(list[list=='T' | list=='t']) / llen
  NXs = length(list[list=='X' | list=='x' || list=='N' || list=='n']) / llen
  if (sum(As,Gs,Cs,Ts,NXs) > .9 && seqType=="auto")
  {
    seqType="dna"
  } else if (seqType=="auto")
  {
    seqType = "protein"
  }

  print(paste("Seqtype: ",seqType," SUM:",sum(As,Gs,Cs,Ts)));

  obj = list(names=names,
     seqs=charMat,
     length=numCols,
     num_seqs=numRows,
     type=seqType
  )
  return(obj)
}

# Input: an alignment where each row is a sequence of characters.
plot.aln = function(file,
  colors=NULL,
  square=F,
  ylim=NULL,xlim=NULL,
  x.lim=NULL,y.lim=NULL,
  draw.chars=F,
  char.col='black',
  grid.lines=T,
  overlay=F,
  plot.tree=T,
  tree.width=100,
  tree.max.bl=5,
  adjust.tree.width=F,
  tree.labels=T,
  cex=1,
  axes=FALSE,
  seqType='auto', # 'dna' or 'protein'
  ...)
{

  if (is.character(file)) {
    aln = read.aln(file,seqType=seqType)
  } else {
    aln = file
  }
  
  # Color matrix can be the filename of an R command creating the array.
  if (is.function(colors)) {
    #colors = source(colors)
  } else if (!is.null(aln$colors)) {
    colors = aln$colors
  }
  
# Grab the number of rows and columns
  numRows = aln$num_seqs
  numCols = aln$length
  seqType = aln$type

  if (is.null(xlim)) {
    xlim=c(0,aln$length)
  }
  if (is.null(ylim)) {
    ylim=c(0,aln$num_seqs)
  }

  if (overlay == FALSE) {
    # Set up the plotting region.
    xlim=c(0,aln$length+1)
    ylim=c(0,aln$num_seqs+1)

    # Fix the x-limits if a tree exists.
    if (!is.null(aln$tree) & plot.tree) {
      library(ape)
      tree = aln$tree
      if (is.character(aln$tree)) tree = read.tree(aln$tree)

      if (adjust.tree.width) {
        adj.tree.width = get_adjusted_tree_width(tree,tree.width)
        # Add on some width for text labels, if applicable.
        if (tree.labels) {
          pp = plot.phylo.greg(tree,x.lim=c(-adj.tree.width,xlim[2]),y.lim=c(ylim[1],ylim[2]),plot=FALSE,
          show.tip.label=TRUE,...)
          par(ps=pp$text.pointsize)
          max.label.width = max(strwidth(tree$tip.label))
          adj.tree.width = adj.tree.width + max.label.width
        }
        tree.width = adj.tree.width
      }
      xlim[1] = xlim[1] - tree.width
    }

    #par(mai=rep(0,4))
    plot.new()
    plot.window(xlim=xlim,ylim=ylim)

    if (square) {
      if (numCols > numRows) {
        plot.window(ylim= c( -numCols/2 + numRows/2, numCols/2 + numRows/2),xlim=xlim)
      }
    }

    if (axes) {
      axis(1)
      axis(2)
    }
  }

  # Plot tree alongside alignment.
  if (!is.null(aln$tree) & plot.tree) {
    library(ape)
    # Read the tree file if we're given a string input.
    tree = aln$tree
    if (is.character(aln$tree)) tree = read.tree(aln$tree)

    # Figure out the sizing of the tree.
    total.bl = sum(tree$edge.length)
    tree.width = tree.width * total.bl / tree.max.bl
    tree.pad = 5

    rowSize = 1

    loX = -tree.width - tree.pad
    hiX = -tree.pad
    loY = ylim[1] + rowSize*.5
    hiY = ylim[2] - rowSize*.5

    #default.text.size = rowSize / (hiY - loY)
    #print(default.text.size);

    width = par("pin")[1]
    height = par("pin")[2]
    smallSize = min(width/numCols,height/numRows)

    # Plot the tree itself.
    plot.phylo.greg(tree,
      draw.within.rect=c(loX,hiX,loY,hiY),
      show.tip.label=tree.labels,
      adj=1,
      cex=cex,
      lwd = smallSize/10,
      ...
    )
  }

  if (!is.null(aln$tree)) {
    # Make sure the alignment is sorted by the tree display order.
    tree = aln$tree
    newPositions = match(aln$names,tree$tip.label)
    aln$seqs[newPositions] = aln$seqs
    aln$names[newPositions] = aln$names

    aln$seqs = rev(aln$seqs)
    aln$names = rev(aln$names)
  }

  rowSize = 1;
  colSize = 1;
  offsetY = 0
  offsetX = 0

  # Adjust rowsize and offsets if we're plotting within a certain region.
  if (overlay) {
    if (!is.null(x.lim)) {
      offsetX = x.lim[1]
      colSize = diff(x.lim) / numCols 
    }

    if (!is.null(y.lim)) {
      offsetY = y.lim[1]
      rowSize = (diff(y.lim)) / numRows
    }
  }

  arr= matrix(unlist(aln$seqs),nrow=numRows,ncol=numCols,byrow=TRUE)
  color.arr = NULL
  if (!is.null(colors)) color.arr = matrix(colors,nrow=numRows,ncol=numCols,byrow=TRUE)

  for (i in 1:numRows)
  {
    list = arr[i,]
    color.vec = NULL
    if (!is.null(color.arr)) color.vec = color.arr[i,]

    ids = list == '-'
    
    loXs = seq(0,numCols-1) * colSize + offsetX
    hiXs = seq(1,numCols) * colSize + offsetX
#    loXs = loXs + 0.5
#    hiXs = hiXs + 0.5
    loYs = rep(ylim[2] - rowSize*(i-1),numCols) + offsetY
    hiYs = rep(ylim[2] - rowSize*(i),numCols) + offsetY

#    loYs = loYs - 0.5
#    hiYs = hiYs - 0.5

    # Grid line.
    if (grid.lines) {
      x1 = loXs[1]
      x2 = hiXs[length(hiXs)]
      y1 = y2 = loYs[1] - rowSize/2
      lines(c(x1,x2),c(y1,y2),col='#EEEEEE',lwd=0.2)
    }

    # Apply colors.
    color.vec=colorSequence(list,type=seqType,colors=color.vec)

    # Remove gaps.
    list_nogaps = list[ids==FALSE]
    loXs = loXs[ids==FALSE]
    hiXs = hiXs[ids==FALSE]
    loYs = loYs[ids==FALSE]
    hiYs = hiYs[ids==FALSE]
    color.vec = color.vec[ids==FALSE]

    # Plot all rectangles.
    rect(loXs,loYs,hiXs,hiYs,col=color.vec,border=NULL,lwd=0,lty=0)
    
    # Plot exons.
    sequence = paste(list,collapse="");
    #print(sequence);
    hiToLo = as.vector(gregexpr("[[:upper:]]-*[[:lower:]]",sequence)[[1]])
    loToHi = as.vector(gregexpr("[[:lower:]]-*[[:upper:]]",sequence)[[1]])
    exons = sort(c(hiToLo,loToHi))
    if (length(hiToLo) > 1) {
      exW = rowSize/3
      rect(exons-exW,loYs[1],exons+exW,hiYs[1],col='white');
      rect(exons-exW,loYs[1],exons+exW,hiYs[1],col='black',density=10);
    }
    width = par("pin")[1]
    height = par("pin")[2]

    smallSize = min(width/numCols,height/numRows)
    cx = smallSize*3/par("cex")
    if (draw.chars) {
      # Draw the characters.
      text.col = color.vec
      text.darker = shift.colors(text.col,-30);
      text(loXs+colSize/2,loYs-rowSize/2,labels=toupper(list_nogaps),cex=cx,col=text.darker)
    }
  }

  return(list(xlim=xlim,ylim=ylim));
}

shift.colors = function(cols,amount)
{
   cols.rgb = col2rgb(cols) + amount
   cols.rgb = pmax(cols.rgb,1)
   cols.rgb = pmin(cols.rgb,255)
   cols.rgb = cols.rgb / 255
   return(rgb(t(cols.rgb)))
}

# Returns a series of coordinates to map between two alignments, based
# on a reference sequence (optionally supplied, otherwise the first sequence
# in the alignment is used).
compare.aln = function(
 aln_file_1, aln_file_2,
 ref_seq_label=NULL,
 anchor_density=10
) {

  if (is.character(aln_file_1)) {
    aln1 = read.aln(file=aln_file_1)
  } else {
    aln1 = aln_file_1
  }
  if (is.character(aln_file_2)) {
    aln2 = read.aln(file=aln_file_2)
  } else {
    aln2 = aln_file_2
  }

  if (!missing(ref_seq_label))
  {
    seq_1_ind = which(aln1$names == ref_seq_label)
    seq_1 = aln1$seqs[[seq_1_ind]]
    seq_2_ind = which(aln2$names == ref_seq_label)
    seq_2 = aln2$seqs[[seq_2_ind]]
  } else
  {
    ind = round(aln1$num_seqs / 2)
    seq_1 = aln1$seqs[[ind]]
    seq_label = aln1$names[ind]  # Grab label of 1st seq
    seq_2_ind = which(aln2$names==seq_label)  # Find label in 2nd aln
    seq_2 = aln2$seqs[[seq_2_ind]]  # Grab seq from 2nd aln
  }

  seq_len = sum(seq_1 != '-')
  anchors_seq = seq(from=1,to=seq_len,by=anchor_density)

  # Number all the residues, leaving gaps as is.
  numbered_seq_1 = numberSequence(seq_1)
  numbered_seq_2 = numberSequence(seq_2)

  anchors_1 = c()
  anchors_2 = c()
  for (anchor in anchors_seq) {
    #print(anchor)
    anchors_1 = c(anchors_1,which(numbered_seq_1 == anchor))
    anchors_2 = c(anchors_2,which(numbered_seq_2 == anchor))
  }

  return(data.frame(a=anchors_1,b=anchors_2))
}

numberSequence = function(string)
{
  chars = unlist(strsplit(string,""))
  count = 0  
  for (i in 1:length(chars)) {
    if (chars[i] == '-') {
      next
    }
    count = count + 1
    chars[i] = count
  }
  return(chars)
}


plot.aln.comparison = function(
  alns=NULL,
  anchor_density=NULL,
  fitToWindow = FALSE,
  axes = FALSE,
  tree.width=100,
  bar.height=.2,
  bar.lwd=1.5,
  tree.labels=FALSE,
  ...
  )
{
  n = length(alns)
  lengths = sapply(alns,function(x){x$length})
  num_rows = sapply(alns,function(x){x$num_seqs})

  maxCols = max(lengths)
  maxRows = max(num_rows)

  joiningHeight = max(bar.height*maxRows,5)

  if (missing(anchor_density)) {
    anchor_density=round(maxCols/30)
  }

  if (axes) {
    par(mar=c(3,3,1,1))
  } else {
    par(mar=c(0,0,0,0))
  }

  plot.new()
  plot.window(xlim=c(0,1),ylim=c(0,1))  

  if (fitToWindow) {
    width = maxCols/50
    height = maxRows/50
    if (names(dev.cur())=="windows") {
     #print(paste("Width",width,"Height",height))
      windows.options(width=width,height=width)
    } else if (names(dev.cur())=="pdf") {

    }
  }

  for (i in 1:length(alns)) {
    zi = i-1
    aln = alns[[i]]
    lowX = 0
    hiX = maxCols
    lowY = -maxRows*(n-i)-joiningHeight*(n-i);
    hiY = maxRows*(i)+joiningHeight*(zi);

    adj.tree.width = tree.width

    if (!is.null(aln$tree)) {
      lowX = -adj.tree.width
      plot.window(xlim=c(lowX,hiX),ylim=c(lowY,hiY))

      tree = aln$tree
      if (is.character(tree)) tree = read.tree(tree)

      # Adjust the width by the total tree length (max of 2x original width)
      #adj.tree.width = get_adjusted_tree_width(tree,tree.width)

      # Add on some width for text labels, if applicable.
      if (tree.labels) {
        pp = plot.phylo.greg(tree,x.lim=c(-tree.width,hiX),y.lim=c(lowY,hiY),plot=FALSE,
          show.tip.label=TRUE,...)
        par(ps=pp$text.pointsize)
        max.label.width = max(strwidth(tree$tip.label))
        #print(max.label.width)
        adj.tree.width = adj.tree.width + max.label.width
      }

	# Use the adjusted tree width.
      lowX = -adj.tree.width
    }

    plot.window(xlim=c(lowX,hiX),ylim=c(lowY,hiY))

    #print(adj.tree.width)

    # Plot this alignment in the designated spot.
    plot.aln(aln,overlay=TRUE,tree.width=adj.tree.width,tree.labels=tree.labels,...)

    # Draw the lines between this alignment and the next.
    if (i < length(alns)) {
      comp = compare.aln(alns[[i]],alns[[i+1]],anchor_density=anchor_density)
      y1 = -1
      y2 = -joiningHeight+1
      for (j in 1:nrow(comp)) {
        #lines(x=c(0,10),y=c(0,10))
        lines(x=c(comp$a[j],comp$b[j]),y=c(y1,y2),col=gray(0.4),lwd=bar.lwd)
      }
    }
  }

  if (axes) {
    axis(1)
    axis(2)
  }

  retMe = list()
  retMe$xlim = c(lowX,hiX)
  retMe$ylim = c(lowY,hiY)
  return(retMe);
}

# Multiplies the given width by the total tree length.
get_adjusted_tree_width = function(tree,width) {
  if (is.character(tree)) tree = read.tree(tree)
  max.dist = max(lengths.to.root(tree))
  if (max.dist > 2) max.dist = 2
  tree.width = max.dist * width
  return(tree.width)
}


plot.aln.bars = function(aln,xlim=NULL,ylim=c(-1,1),draw.text=T) {
  plot.new()
  if (is.null(xlim)) xlim = c(0,aln$length+1)
  plot.window(xlim=xlim,ylim=ylim)
  barH = .15
  bigBars = seq(from=1,to=aln$length,by=50);
  littleBars = seq(from=1,to=aln$length,by=10);
  segments(x0=littleBars,y0=-barH/2,x1=littleBars,y1=barH/2,lwd=4,col='gray');
  segments(x0=bigBars,y0=-barH,x1=bigBars,y1=barH,lwd=4,col='black');
  bigText = as.character(bigBars);
  text(x=bigBars,y=0.5,labels=bigText,pos=4);

}


sort.aln.by.tree = function(aln,tree) {
  # Make sure the alignment is sorted by the tree display order.
  newPositions = match(aln$names,tree$tip.label)

  aln$seqs[newPositions] = aln$seqs
  aln$names[newPositions] = aln$names

  aln$seqs = rev(aln$seqs)
  aln$names = rev(aln$names)
  return(aln)
}