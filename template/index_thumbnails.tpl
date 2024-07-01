<div id="gallery" class="row mt-5 grid">
    <div id="item_template" class="d-none col-outer col-xxl-3 col-xl-4 col-lg-4 col-md-6 col-sm-12 col-12 p-2 m-0" >
        <div class="card card-thumbnail path-ext-png file-ext-png" style="border: 0px;">
            <div class="h-100">
                <a href="" class="img-link ripple d-block" target="_view_detail">
                    <img class="item-img card-img-top img-fluid rounded thumb-img" src="" >
                </a>
                <div class="card-body d-none  list-view-only">
                    <h6 class="card-title">
                        <a href="#" class="ellipsis">-</a>
                    </h6>
                </div>
            </div>
        </div>
    </div>
</div>
<div id="loading" class="row text-center my-4" style="display:none;">
    <p>更多数据加载中...</p>
</div>

{footer_script require='jquery' require='masonry' require='imagesloaded'}{strip}
    var page = 0;
    var loading = false;
    var itemHtml = "<div></div>";

    function initMasonry() {
        var grid = document.querySelector('.grid');
        var msnry = new Masonry(grid, {
          itemSelector: '.grid-item',
          columnWidth: '.grid-item',
          percentPosition: true
        });
    
        {* // Use imagesLoaded to ensure all images are loaded before layout *}
        imagesLoaded(grid, function() {
          msnry.layout();
        });
      }
    
    function getItemHtml() {
        var tItem = $("#item_template");
        var html = tItem.prop("outerHTML");
        var newItem = $(html);
        newItem.removeAttr('id');
        newItem.removeClass('d-none');
        newItem.addClass('grid-item');
        return newItem.prop("outerHTML");
    };

     function loadImages() {
            if (loading) return;
            loading = true;
            $('#loading').show();

            $.ajax({
                url: '/ws.php',
                data: {
                    format: 'json',
                    method: 'pwg.categories.getImages',
                    per_page: 20, {* //每页加载20张图片 *}
                    page: page,
                    order: 'hit DESC'  {* id, file, name, hit, rating_score, date_creation, date_available, random *}
                },
                success: function(data) {
                    data = JSON.parse(data);
                    $('#loading').hide();
                    if (data.stat === 'ok') {
                        var images = data.result.images;
                        var gallery = $('#gallery');
                        $.each(images, function(index, image) {
                            var itemDiv = $(itemHtml);
                            itemDiv.find('.item-img').attr('src', image.derivatives.medium.url).attr('alt', image.name); 
                            itemDiv.find('.img-link').attr('href', image.page_url);
                            gallery.append(itemDiv); 
                        });
                        page++;
                        loading = false;
                    } else {
                        console.error('Error fetching images:', data.message);
                    }
                    initMasonry();
                },
                error: function(xhr, status, error) {
                    $('#loading').hide();
                    console.error('AJAX Error:', status, error);
                    loading = false;
                }
            });  
        };

    $(document).ready(function() {
        {* // 初始加载图片 *}
        itemHtml = getItemHtml();
        loadImages();
        {* // 监听滚动事件实现下拉刷新 *}
        $(window).scroll(function() {
            if ($(window).scrollTop() + $(window).height() > $(document).height() - 100) {
                loadImages();
            }
        });

    }); 

{/strip}{/footer_script}