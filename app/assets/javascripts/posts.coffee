# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on('turbolinks:load', ->
  $(document).on('keyup','#search-area',(e)->
    e.preventDefault();
    input = $.trim($(this).val()) #$(this).val（打った文字）を$.trim(余白をトリミング)して取得

    $.ajax({
        url: '/posts/search',
        type: 'get',
        data: ('keyword=' + input),
        processData:false,  #おまじない
        cotentType: false,  #おまじない
        dataType: 'json'
      })
        .done((data)->
          $('#content').find('div').remove()
          $('#content').find('a').remove()
          $(data).each((j,post)->
            $('#content').append("<a href=\"/posts/#{post.id}\" id='#{j}'></a>")
            $('#'+j).append("<div class='post-wrapper'></div>")
          )

          $(".post-wrapper").html("<div class='time-area'></div>"+"<div class='title-area'></div>")
          $(".time-area").html("<p class='time'></p>")
          $(".title-area").html("<p class='title'></p>")
          $(data).each((i, post)->
            month = String(post.month)
            day = String(post.day)
            if month.length==1
              $(".time").eq(i).append("0"+ month)
            else
              $(".time").eq(i).append(month)
            if day.length==1
              $(".time").eq(i).append("0" + day)
            else
              $(".time").eq(i).append(day)
            $(".title").eq(i).html("<span></span>")
            $(".title").children('span').eq(i).append(post.title)
          )
        )

  )
)
# set page height
$(document).on('turbolinks:load',->
  hsize = $(window).height();
  $("#modal-wrapper").css("min-height", hsize + "px")
  $("#content").css("min-height", hsize - 72 + "px" )
  $('#evl-wrapper').css('min-height',hsize - 72 + "px")
  $('#new-post-wrapper').css('min-height',hsize + "px")
)
$(window).resize(()->
  hsize = $(window).height();
  $("modal-wrapper").css("height", hsize + "px")
  $("#content").css("min-height", hsize - 72 + "px" )
  $('#evl-wrapper').css('min-height',hsize - 72 + "px")
)

# show modal
$(document).on('turbolinks:load',->
  $show = document.getElementById('show-modal')
  $modal = document.getElementById('modal-wrapper')
  $hide = document.getElementById('hide-modal')
  #console.log($show)
  if $modal
    console.log($modal)
    unless $show == null
      $show.addEventListener('click', ()->
        $modal.style.display="flex"
      )
    $hide.addEventListener('click',()->
      $modal.style.display="none"
    )
    $modal.addEventListener('click', ()->
      $modal.style.display="none"
    )
)

#show chart
$(document).on('turbolinks:load' , ->
  $('#show-chart').on('click',->
    #console.log($myChart)
    $('#title-text').text('今月の評価グラフ')
    $('.column').animate({width: 'hide'}, 'slow')
    $('#show-chart').animate({width: 'hide'}, 'slow')
    $('.chart').fadeOut()
    $('#evl-wrapper').append('<canvas id="myChart"  ></canvas><script>draw_graph();</script>').animate('left', 'slow')
    $('#show-cnt').animate({width: 'show'}, 'slow')
    $('.cnt-text').fadeIn()
  )
  $('#show-cnt').on('click',->
    $('#title-text').text('投稿の振り返り')
    $('#myChart').remove()
    $('#show-chart').animate({width: 'show'}, 'slow')
    $('.chart').fadeIn()
    $('.column').fadeIn()
    $('#show-cnt').animate({width: 'hide'}, 'slow')
    $('.cnt-text').fadeOut()
  )
)

# chart.js
window.draw_graph = ->
  console.log(gon.data)
  barNum = gon.day
  labels = new Array(barNum)
  bgColors = new Array(barNum)
  bdColors = new Array(barNum)
  for i in [0...barNum]
    labels[i] = i+1
    bgColors[i] = 'rgba(248,90,64,0.2)'
    bdColors[i] = 'rgba(248,90,64,1)'

  ctx = document.getElementById("myChart").getContext('2d')
  myChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels: labels
      datasets: [{
        label: 'evaluation',
        data: gon.data,
        backgroundColor: bgColors,
        borderColor: bdColors,
        borderWidth: 1
      }]
    },
    options: {
      scales: {
        yAxes: [{
          ticks: {
            beginAtZero:true
          }
        }]
      },
      responsive: true,

    }
  })