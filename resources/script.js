let domReady = (cb) => {
    if(document.readyState === 'interactive' || document.readyState == 'complete'){
        cb()
    } else{
        document.addEventListener('DOMContentLoaded', cb)
    }
}

domReady(() => {
    document.body.style.visibility = 'visible';
})