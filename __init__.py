import sys
import requests
import random
import os
import time
import base64
import importlib.util
from pixabay import Image, Video
from os.path import join, dirname, abspath
from adapt.intent import IntentBuilder
from mycroft.skills.core import MycroftSkill, intent_handler, intent_file_handler, resting_screen_handler
from mycroft.skills.skill_loader import load_skill_module
from mycroft.util.log import getLogger
from mycroft.messagebus.message import Message
from json_database import JsonStorage
__author__ = 'aix'

LOGGER = getLogger(__name__)

class PixabaySkill(MycroftSkill):

    # The constructor of the skill, which calls MycroftSkill's constructor
    def __init__(self):
        super(PixabaySkill, self).__init__(name="PixabaySkill")
    
    def initialize(self):
        self.add_event('pixabay-skill.aiix.home', self.handle_pixabay_homescreen)
        self.gui.register_handler("pixabay.show.image", self.handle_pixabay_show_image)
        self.gui.register_handler("pixabay.show.video", self.handle_pixabay_show_video)
        self.gui.register_handler("pixabay.gallery.next", self.handle_gallery_next_page)
        self.gui.register_handler("pixabay.gallery.previous", self.handle_gallery_previous_page)
        self.gui.register_handler("pixabay.idle.set_idle", self.handle_set_idlescreen_type)
        self.gui.register_handler("pixabay.idle.enableTime", self.handle_idle_enable_time)
        self.gui.register_handler("pixabay.idle.disableTime", self.handle_idle_disable_time)
        self.gui.register_handler("pixabay.idle.updateTime", self.handle_idle_update_time)
        self.gui.register_handler("pixabay.idle.removeConfigPage", self.handle_remove_configure_idle_screen)
        self.entKey = base64.b64decode("MTcyMjI5NDctYTlmNTQxNmQ2ODhkNDVmNmJkZmY4ZWEzYQ==")
        self.video = Video(self.entKey)
        self.image = Image(self.entKey)
        self.shownPageNumber = None
        self.numberOfAvailablePages = None
        self.previousQuery = None
        self.currentType = None
        self.currentDir = dirname(dirname(abspath(__file__)))
        self.wantedDir = "pixabayData"
        self.dataPath = join(self.currentDir, self.wantedDir)
        self.videoPath = join(self.dataPath, "video.mp4")
        
        # Set All Paths
        try:
            os.mkdir(self.dataPath)
        except OSError as error:
            print("Directory Already Exist Skipping")
        self.storeDB = join(self.dataPath, 'pixabay-idle.db')
        self.idle_db = JsonStorage(self.storeDB)
        self.configDB = join(self.dataPath, 'pixabay-config.db')
        self.idle_config_db = JsonStorage(self.configDB)
        
        # Make Import For TimeData
        try:
            time_date_path = "/opt/mycroft/skills/mycroft-date-time.mycroftai/__init__.py"
            time_date_id = "datetimeskill"
            datetimeskill = load_skill_module(time_date_path, time_date_id)
            from datetimeskill import TimeSkill
            self.dt_skill = TimeSkill()
        except:
            print("Failed To Import DateTime Skill")
            
    def handle_pixabay_homescreen(self, message):
        self.handle_pixabay_display("Homescreen")
            
    @intent_file_handler("PixabaySearchImage.intent")
    def handle_pixabay_search_image_type(self, message):
        query = message.data["query"]
        self.previousQuery = query
        self.shownPageNumber = 1
        self.currentType = "Image"
        ims = self.image.search(q=query,
             lang='en',
             image_type='photo',
             orientation='vertical',
             category='all',
             safesearch='true',
             order='latest',
             page=1,
             per_page=6)
        totalImages = ims['total']
        totalHits = ims['totalHits']
        self.handle_number_of_pages(totalImages, totalHits)
        self.gui["currentPageNumber"] = self.shownPageNumber
        self.gui["showMoreAvailable"] = self.handle_show_more_available(self.shownPageNumber)
        self.gui["imageGalleryModel"] = ims['hits']
        self.handle_pixabay_display("ImageGallery")
        
    def handle_pixabay_show_image(self, message):
        self.gui["imageURL"] = message.data["largeImageURL"]
        self.handle_pixabay_display("Image")

    @intent_file_handler("PixabaySearchVideo.intent")
    def handle_pixabay_search_video_type(self, message):
        query = message.data["query"]
        self.previousQuery = query
        self.shownPageNumber = 1
        self.currentType = "Video"
        vis = self.video.search(q=query, lang='en',
                       video_type='all',
                       category='all',
                       page=1,
                       per_page=6)
        totalImages = vis['total']
        totalHits = vis['totalHits']
        print(totalImages)
        print(totalHits)
        self.handle_number_of_pages(totalImages, totalHits)
        self.gui["currentPageNumber"] = self.shownPageNumber
        self.gui["showMoreAvailable"] = self.handle_show_more_available(self.shownPageNumber)
        self.gui["videoGalleryModel"] = vis['hits']
        addr = vis['hits']
        print(addr)
        self.handle_pixabay_display("VideoGallery")
                
    def handle_pixabay_show_video(self, message):
        orignalurl = message.data['videourl']
        videoURL = self.handle_pixabay_extract_video(orignalurl)
        self.gui["videoURL"] = videoURL
        self.handle_pixabay_display("Video")
        
    def handle_pixabay_extract_video(self, videoURL):        
        extractvideofromloc = requests.get(videoURL, allow_redirects=False)
        actualVideoUrl = extractvideofromloc.headers['location']
        r = requests.get(actualVideoUrl, stream=True)
        with open(self.videoPath, 'wb') as f: 
            for chunk in r.iter_content(chunk_size = 1024*1024): 
                if chunk: 
                    f.write(chunk)
        videoURL = self.videoPath
        return videoURL
        
    def handle_pixabay_display(self, state):
        if state is "Image":
            self.gui["setMessage"] = ""
            self.gui.show_page("Image.qml", override_idle=True)
        elif state is "Video":
            self.gui["setMessage"] = ""
            self.gui.show_page("Video.qml", override_idle=True)
        elif state is "Homescreen":
            self.gui.show_page("Homepage.qml", override_idle=True)
        else:
            self.gui["pageState"] = state
            self.gui.show_page("pixabayLoader.qml", override_idle=True)
            
    def handle_gallery_next_page(self, message): 
        galleryType = message.data["galleryType"]
        pageNumber = message.data["currentPageNumber"]
        if pageNumber < self.numberOfAvailablePages:
            pageNumber = self.shownPageNumber + 1
            self.shownPageNumber = pageNumber
            if galleryType == "Image":
                ims = self.image.search(q=self.previousQuery,
                                        lang='en',
                                        image_type='all',
                                        orientation='vertical',
                                        category='all',
                                        safesearch='true',
                                        order='latest',
                                        page=self.shownPageNumber,
                                        per_page=6)
                self.gui["currentPageNumber"] = self.shownPageNumber
                self.gui["showMoreAvailable"] = self.handle_show_more_available(self.shownPageNumber)
                self.gui["imageGalleryModel"] = ims['hits']
            elif galleryType == "Video":
                vis = self.video.search(q=self.previousQuery, 
                                        lang='en',
                                        video_type='all',
                                        category='all',
                                        page=self.shownPageNumber,
                                        per_page=6)
                self.gui["currentPageNumber"] = self.shownPageNumber
                self.gui["showMoreAvailable"] = self.handle_show_more_available(self.shownPageNumber)
                self.gui["videoGalleryModel"] = vis['hits']
                self.handle_pixabay_display("VideoGallery")
            else:
                print("Valid Type Not Found")
                
                
    def handle_gallery_previous_page(self, message):
        galleryType = message.data["galleryType"]
        pageNumber = message.data["currentPageNumber"]
        if pageNumber > 1:
            pageNumber = self.shownPageNumber - 1
            self.shownPageNumber = pageNumber
            if galleryType == "Image":
                ims = self.image.search(q=self.previousQuery,
                                        lang='en',
                                        image_type='all',
                                        orientation='all',
                                        category='all',
                                        safesearch='true',
                                        order='latest',
                                        page=self.shownPageNumber,
                                        per_page=6)
                self.gui["currentPageNumber"] = self.shownPageNumber
                self.gui["showMoreAvailable"] = self.handle_show_more_available(self.shownPageNumber)
                self.gui["imageGalleryModel"] = ims['hits']
            elif galleryType == "Video":
                vis = self.video.search(q=self.previousQuery, 
                                        lang='en',
                                        video_type='all',
                                        category='all',
                                        page=self.shownPageNumber,
                                        per_page=6)
                self.gui["currentPageNumber"] = self.shownPageNumber
                self.gui["showMoreAvailable"] = self.handle_show_more_available(self.shownPageNumber)
                self.gui["videoGalleryModel"] = vis['hits']
                self.handle_pixabay_display("VideoGallery")
            else:
                print("Valid Type Not Found")

    @intent_handler(IntentBuilder("HandleAudioGalleryNext").require("PixabayGalleryNextKeyword").build())
    def handle_audio_gallery_next(self):
        currentPageNumber = self.shownPageNumber
        self.handle_gallery_next_page(Message("data", {"currentPageNumber": currentPageNumber, "galleryType": self.currentType}))
    
    @intent_handler(IntentBuilder("HandleAudioGalleryNext").require("PixabayGalleryPreviousKeyword").build())
    def handle_audio_gallery_previous(self):
        currentPageNumber = self.shownPageNumber
        self.handle_gallery_previous_page(Message("data", {"currentPageNumber": currentPageNumber, "galleryType": self.currentType}))

    def handle_number_of_pages(self, total, totalhits):
        if total > totalhits:
            orgNumPage = totalhits / 6
            if orgNumPage > 10:
                self.numberOfAvailablePages = 10
                return 10
            else:
                orgNumPage = totalhits / 6
                self.numberOfAvailablePages = orgNumPage
                return orgNumPage
            
        elif total < totalhits:
            orgNumPage = total / 6
            if orgNumPage > 10:
                self.numberOfAvailablePages = 10
                return 10
            else:
                orgNumPage = totalhits / 6
                self.numberOfAvailablePages = orgNumPage
                return orgNumPage
        
        elif total == totalhits:
            orgNumPage = total / 6
            if orgNumPage > 10:
                self.numberOfAvailablePages = 10
                return 10
            else:
                self.numberOfAvailablePages = orgNumPage
                return orgNumPage

    def handle_show_more_available(self, currentPage):
        if currentPage < self.numberOfAvailablePages:
            return True
        else:
            return False
    
    def handle_set_idlescreen_type(self, message):
        idleType = message.data["idleType"]
        self.idle_db.clear()
        if idleType == "Image":
            idleImageURL = message.data["idleImageURL"]
            imageType = idleImageURL.split('.')[-1]
            imagePath = join(self.dataPath, str("pixabay-idle" + "." + imageType))
            self.extract_image_for_idle(idleImageURL, imagePath)
            self.gui["idleType"] = "ImageIdle"
            self.gui["idleGenericURL"] = imagePath
            self.idle_db["idleInfo"] = {"idleType": "ImageIdle", "idleGenericURL": imagePath}
            self.idle_db.store()
            self.gui["setMessage"] = "New Homescreen Set"
        if idleType == "Video":
            idleVideoURL = message.data["idleVideoURL"]
            self.gui["idleType"] = "VideoIdle"
            self.gui["idleGenericURL"] = idleVideoURL
            self.idle_db["idleInfo"] = {"idleType": "VideoIdle", "idleGenericURL": idleVideoURL}
            self.idle_db.store()
            self.gui["setMessage"] = "New Homescreen Set"
            
    def handle_idlescreen_first_run(self):
        # Check If Idle Screen DB Exist and Not Empty
        # Retrive and Set Idle Screen if Available
        # If idle unset, get random and store
        if 'idleInfo' in self.idle_db.keys():
            self.gui["idleType"] = self.idle_db["idleInfo"]["idleType"]
            self.gui["idleGenericURL"] = self.idle_db["idleInfo"]["idleGenericURL"]

        else:
            imageURL = self.generate_random_idle()
            imageType = imageURL.split('.')[-1]
            imagePath = join(self.dataPath, str("pixabay-idle" + "." + imageType))
            self.extract_image_for_idle(imageURL, imagePath)
            self.idle_db["idleInfo"] = {"idleType": "ImageIdle", "idleGenericURL": imagePath}
            self.idle_db.store()
            self.gui["idleType"] = "ImageIdle"
            self.gui["idleGenericURL"] = imagePath
        
        if 'showTime' in self.idle_config_db.keys():
            if self.idle_config_db["showTime"] == True:
                self.gui["showTime"] = True
                self.gui['time_string'] = self.dt_skill.get_display_current_time()
            else:
                self.gui["showTime"] = False
                self.gui["time_string"] = ""
        else:
            self.gui["showTime"] = False
            self.gui["time_string"] = ""
            
    def generate_random_idle(self):
        ims = self.image.search(q="galaxy",
                                lang='en',
                                image_type='photo',
                                orientation='vertical',
                                category='all',
                                safesearch='true',
                                order='latest',
                                page=4,
                                per_page=6)
        randomImageUrl = ims['hits'][4]["largeImageURL"]
        return randomImageUrl
    
    @resting_screen_handler('Pixabay')
    def handle_idle(self, message):
        self.gui.clear()
        self.log.debug('Activating Time/Date resting page')
        self.handle_idlescreen_first_run()
        self.gui.show_page('pixabayIdleLoader.qml')
    
    def extract_image_for_idle(self, url, localpath):
        try:
            image = requests.get(url)
        except OSError:
            return False
        if image.status_code == 200:
            with open(localpath, "wb") as k:
                k.write(image.content)
        else:
            print("Saving Image Failed")
            
    def handle_idle_enable_time(self):
        self.speak("I am enabling time")
        self.idle_config_db["showTime"] = True
        self.gui["showTime"] = True
        self.idle_config_db.store()
        # Send Time Data Here First
        self.handle_idle_update_time()

    def handle_idle_disable_time(self):
        self.speak("I am disabling time")
        self.idle_config_db["showTime"] = False
        self.gui["showTime"] = False
        self.idle_config_db.store()
        
    def handle_idle_update_time(self):
        self.gui['time_string'] = self.dt_skill.get_display_current_time()
        
    @intent_handler(IntentBuilder("PixabayIdleConfigure").require("PixabayIdleConfigure").build())
    def handle_configure_idle_screen(self):
        self.gui.show_page("ConfigurePixabayIdle.qml")
    
    def handle_remove_configure_idle_screen(self):
        self.gui.remove_page("ConfigurePixabayIdle.qml")
        
    def stop(self):
        pass

# The "create_skill()" method is used to create an instance of the skill.
# Note that it's outside the class itself.
def create_skill():
    return PixabaySkill()
